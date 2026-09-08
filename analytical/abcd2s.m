function [S11, S12, S21, S22] = abcd2s(A, B, C, D, Z0)
%ABCD2S  Convert 2-port ABCD parameters to scattering parameters.
%
%   [S11,S12,S21,S22] = abcd2s(A,B,C,D,Z0)
%
%   A,B,C,D may be scalars or equal-size vectors (one entry per frequency).
%   Z0 is the (real) reference impedance, default 50 ohm.

    if nargin < 5 || isempty(Z0); Z0 = 50; end

    den = A + B ./ Z0 + C .* Z0 + D;

    S11 = (A + B ./ Z0 - C .* Z0 - D) ./ den;
    S12 = 2 .* (A .* D - B .* C)       ./ den;
    S21 = 2                            ./ den;
    S22 = (-A + B ./ Z0 - C .* Z0 + D) ./ den;
end
