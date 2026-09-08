function test_touchstone()
%TEST_TOUCHSTONE  Write .s2p in RI / MA / DB formats, read back, compare.

    addpath(fileparts(fileparts(mfilename('fullpath'))));

    f = (1:5).' * 1e9;
    S = zeros(2,2,5);
    rng(1);
    S(1,1,:) = (rand(5,1)-0.5) + 1i*(rand(5,1)-0.5);
    S(2,1,:) = (rand(5,1)-0.5) + 1i*(rand(5,1)-0.5);
    S(1,2,:) = S(2,1,:);                       % reciprocal
    S(2,2,:) = (rand(5,1)-0.5) + 1i*(rand(5,1)-0.5);

    tmp = tempname;

    for fmt = ["RI" "MA" "DB"]
        fn = [tmp '_' char(fmt) '.s2p'];
        writeS2P(fn, f, S, fmt);
        ts = readTouchstone(fn);
        delete(fn);

        assert(max(abs(ts.f - f)) < 1, 'frequency mismatch');
        err = max(abs(ts.S(:) - S(:)));
        fprintf('  %s: max |dS| = %.2e\n', fmt, err);
        assert(err < 1e-6, '%s round-trip failed', fmt);
    end

    disp('  test_touchstone PASSED');
end

% ----------------------------------------------------------------------
function writeS2P(fn, f, S, fmt)
    fid = fopen(fn, 'w');
    fprintf(fid, '# GHZ S %s R 50\n', char(fmt));
    order = [1 1; 2 1; 1 2; 2 2];
    for k = 1:numel(f)
        vals = zeros(1,8);
        for p = 1:4
            v = S(order(p,1), order(p,2), k);
            switch char(fmt)
                case 'RI'
                    vals(2*p-1) = real(v); vals(2*p) = imag(v);
                case 'DB'
                    vals(2*p-1) = 20*log10(abs(v)); vals(2*p) = rad2deg(angle(v));
                otherwise
                    vals(2*p-1) = abs(v); vals(2*p) = rad2deg(angle(v));
            end
        end
        fprintf(fid, '%.10g %.10g %.10g %.10g %.10g %.10g %.10g %.10g %.10g\n', ...
            f(k)/1e9, vals);
    end
    fclose(fid);
end
