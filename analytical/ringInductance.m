function L = ringInductance(dAvg, rho, n, shape)
%RINGINDUCTANCE  Quasi-static loop inductance of a (multi-)ring resonator.
%
%   L = ringInductance(dAvg, rho, n, shape) uses the current-sheet
%   (modified-Wheeler) expression of Mohan et al., as adopted by Bilotti and
%   Toscano for split-ring and multiple-split-ring resonators:
%
%       L = (mu0 * n^2 * dAvg * c1 / 2) * ( log(c2/rho) + c3*rho + c4*rho^2 )
%
%   INPUTS
%     dAvg  - average loop diameter (m): (d_out + d_in)/2
%     rho   - fill ratio: (d_out - d_in) / (d_out + d_in), in (0,1)
%     n     - number of rings acting as turns (1 for a classic 2-ring EC-SRR,
%             N for an N-ring MSRR)
%     shape - 'circular' | 'square' | 'hexagonal' | 'octagonal'
%
%   References
%     S. S. Mohan et al., "Simple accurate expressions for planar spiral
%       inductances," IEEE JSSC 34(10), 1999.
%     F. Bilotti et al., IEEE T-MTT 55(12), 2007; IEEE T-AP 55(8), 2007.

    if nargin < 4 || isempty(shape); shape = 'circular'; end
    if nargin < 3 || isempty(n);     n = 1;              end

    mu0 = 1.25663706212e-6;

    rho = max(min(rho, 0.999), 1e-3);

    switch lower(shape)
        case 'square'
            c1 = 1.27; c2 = 2.07; c3 = 0.18; c4 = 0.13;
        case 'hexagonal'
            c1 = 1.09; c2 = 2.23; c3 = 0.00; c4 = 0.17;
        case 'octagonal'
            c1 = 1.07; c2 = 2.29; c3 = 0.00; c4 = 0.19;
        otherwise   % circular
            c1 = 1.00; c2 = 2.46; c3 = 0.00; c4 = 0.20;
    end

    L = (mu0 * n^2 * dAvg * c1 / 2) * ...
        (log(c2 ./ rho) + c3 .* rho + c4 .* rho.^2);

    L = max(L, 0);
end
