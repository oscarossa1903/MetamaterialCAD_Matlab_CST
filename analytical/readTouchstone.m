function ts = readTouchstone(filename)
%READTOUCHSTONE  Minimal Touchstone (.s1p/.s2p) reader for CST S-parameters.
%
%   ts = readTouchstone(filename) returns a struct
%     .f     - frequency vector [Hz]
%     .S     - nports x nports x nFreq complex S-parameter array
%     .z0    - reference impedance [ohm]
%     .nports
%
%   Supports the option line   # <freq unit> S <format> R <z0>
%   with freq unit HZ/KHZ/MHZ/GHZ, format RI | MA | DB. Comment lines start
%   with '!' ; the '#' option line may appear once. Handles 1- and 2-port
%   files (2-port column order is S11 S21 S12 S22 per the spec).
%
%   No RF Toolbox dependency.

    txt = fileread(filename);
    lines = regexp(txt, '\r\n|\r|\n', 'split');

    funit = 'ghz'; fmt = 'ma'; z0 = 50;
    data = [];

    for i = 1:numel(lines)
        ln = strtrim(lines{i});
        if isempty(ln) || ln(1) == '!'
            continue
        end
        if ln(1) == '#'
            tok = lower(regexp(ln(2:end), '\s+', 'split'));
            tok = tok(~cellfun(@isempty, tok));
            for k = 1:numel(tok)
                switch tok{k}
                    case {'hz','khz','mhz','ghz'}, funit = tok{k};
                    case {'ri','ma','db'},         fmt   = tok{k};
                    case 'r'
                        if k < numel(tok); z0 = str2double(tok{k+1}); end
                end
            end
            continue
        end
        % strip inline comments
        ln = regexprep(ln, '!.*$', '');
        row = sscanf(ln, '%f').';
        if ~isempty(row)
            data = [data; row]; %#ok<AGROW>
        end
    end

    if isempty(data)
        error('readTouchstone:empty', 'No numeric data found in %s', filename);
    end

    switch funit
        case 'hz',  fscale = 1;
        case 'khz', fscale = 1e3;
        case 'mhz', fscale = 1e6;
        otherwise,  fscale = 1e9;
    end

    ncols  = size(data, 2);
    npairs = (ncols - 1) / 2;
    nports = round(sqrt(npairs));
    if nports^2 ~= npairs
        error('readTouchstone:ports', ...
              'Unexpected column count (%d) in %s', ncols, filename);
    end

    f  = data(:,1) * fscale;
    nF = numel(f);
    S  = zeros(nports, nports, nF);

    for p = 1:npairs
        a = data(:, 2*p);
        b = data(:, 2*p + 1);
        switch fmt
            case 'ri'
                val = a + 1i*b;
            case 'db'
                val = 10.^(a/20) .* exp(1i*deg2rad(b));
            otherwise   % ma
                val = a .* exp(1i*deg2rad(b));
        end
        % column order: p runs 1..npairs as (col-major) S(row,col)
        col = ceil(p / nports);
        row = p - (col-1)*nports;
        if nports == 2
            % Touchstone 2-port order is S11 S21 S12 S22
            order = [1 1; 2 1; 1 2; 2 2];
            row = order(p,1); col = order(p,2);
        end
        S(row, col, :) = reshape(val, 1, 1, nF);
    end

    ts = struct('f', f, 'S', S, 'z0', z0, 'nports', nports);
end
