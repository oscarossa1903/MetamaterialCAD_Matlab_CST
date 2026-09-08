function [S11, S21, info] = lineLoadedSParameters(f, s1, opts)
%LINELOADEDSPARAMETERS  Stage 2b - S-parameters of a transmission line loaded
%                       with one SRR or CSRR resonator (Baena-2005 topology).
%
%   [S11, S21, info] = lineLoadedSParameters(f, s1, opts)
%
%   f    - frequency vector [Hz]
%   s1   - struct from SRRLCMODEL (uses .L, .C, .f0, .mode)
%   opts - optional: .Z0 (default 50), .Q (unloaded Q, default 60),
%                    .coupling (0..1 scaling of the coupled reactance, default 1),
%                    .Cline (line shunt capacitance for the CSRR case [F])
%
%   Simplified lumped model (both give a transmission zero at s1.f0):
%     CSRR - shunt series L-C branch to ground   ->  shorts the line at f0
%            (Baena: the CSRR appears as a shunt resonator on the line)
%     SRR  - series parallel L-C tank in the line ->  blocks the line at f0
%            (Baena: edge/broadside-coupled SRR loads the line in series)
%
%   The absolute notch depth depends on the (geometry-specific) line coupling,
%   which this quasi-static model only captures through `opts.coupling`. Use
%   the result for band placement; use CST for the exact depth/Q.

    if nargin < 3; opts = struct(); end
    Z0  = getdef(opts, 'Z0', 50);
    Q   = getdef(opts, 'Q', 60);
    kap = getdef(opts, 'coupling', 1);

    f   = f(:);
    w   = 2*pi*f;
    w0  = 2*pi*s1.f0;

    L = s1.L / max(kap, 1e-3);
    C = s1.C * max(kap, 1e-3);
    Rloss = (1/Q) * sqrt(L / C);          % series loss resistor in the tank

    isCSRR = strcmpi(s1.mode, 'CSRR');

    if isCSRR
        % shunt series L-C branch to ground: Y = 1/(jwL + 1/(jwC) + R)
        Cline = getdef(opts, 'Cline', 0);
        Y = 1 ./ (1i.*w.*L + 1 ./ (1i.*w.*C) + Rloss) + 1i.*w.*Cline;
        A = ones(size(f)); B = zeros(size(f));
        Cc = Y;            D = ones(size(f));
    else
        % series parallel tank: Z = 1/(jwC + 1/(jwL + R))
        Z = 1 ./ (1i.*w.*C + 1 ./ (1i.*w.*L + Rloss));
        A = ones(size(f)); B = Z;
        Cc = zeros(size(f)); D = ones(size(f));
    end

    [S11, ~, S21, ~] = abcd2s(A, B, Cc, D, Z0);

    info = struct('w0', w0, 'L', L, 'C', C, 'Rloss', Rloss, 'topology', ...
                  ternary(isCSRR, 'shunt-tank', 'series-tank'));
end

% ----------------------------------------------------------------------
function v = getdef(s, f, d)
    if isfield(s, f) && ~isempty(s.(f)); v = s.(f); else; v = d; end
end
function o = ternary(c, a, b)
    if c; o = a; else; o = b; end
end
