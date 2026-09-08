function [A, B, C, D] = s2abcd(S11, S12, S21, S22, Z0)
%S2ABCD  Convert 2-port scattering parameters to ABCD parameters.
%
%   [A,B,C,D] = s2abcd(S11,S12,S21,S22,Z0)
%
%   Inputs may be scalars or equal-size vectors. Z0 real, default 50 ohm.

    if nargin < 5 || isempty(Z0); Z0 = 50; end

    d = 2 .* S21;

    A = ((1 + S11) .* (1 - S22) + S12 .* S21) ./ d;
    B = Z0 .* ((1 + S11) .* (1 + S22) - S12 .* S21) ./ d;
    C = ((1 - S11) .* (1 - S22) - S12 .* S21) ./ (d .* Z0);
    D = ((1 - S11) .* (1 + S22) + S12 .* S21) ./ d;
end
