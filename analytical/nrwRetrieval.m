function out = nrwRetrieval(f, S11, S21, dSlab)
%NRWRETRIEVAL  Effective-medium retrieval from slab S-parameters.
%
%   out = nrwRetrieval(f, S11, S21, dSlab) inverts the slab formulas of
%   SLABSPARAMETERS to recover the effective parameters. This is the refined
%   Nicolson-Ross-Weir method with the branch handling of
%
%     D. R. Smith et al., Phys. Rev. B 65, 195104 (2002)
%     X. Chen et al.,     Phys. Rev. E 70, 016608 (2004)
%
%   The same routine is used on analytical S-parameters and on CST-exported
%   S-parameters (see READTOUCHSTONE).
%
%   INPUTS
%     f      - frequency vector [Hz]
%     S11,S21- complex S-parameters at the slab faces (vectors over f)
%     dSlab  - slab thickness / period along propagation [m]
%
%   OUTPUT struct
%     .f, .eps, .mu, .n, .z    (eps, mu, n, z complex vectors)
%
%   Convention exp(-i w t): Re(z) >= 0, Im(n) >= 0.

    f   = f(:);
    S11 = S11(:);
    S21 = S21(:);

    c0 = 299792458;
    k0 = 2*pi*f / c0;

    % ---- impedance ----------------------------------------------------
    num = (1 + S11).^2 - S21.^2;
    den = (1 - S11).^2 - S21.^2;
    z = sqrt(num ./ den);
    flip = real(z) < 0;
    z(flip) = -z(flip);

    % ---- refractive index ----------------------------------------
    % E = exp(i n k0 d)
    E = S21 ./ (1 - S11 .* (z - 1) ./ (z + 1));

    % enforce passivity |E| <= 1 (Im(n) >= 0); if not, use the other root
    bad = abs(E) > 1 + 1e-9;
    E(bad) = 1 ./ E(bad);

    % continuous phase branch: unwrap from the low-frequency end where
    % |n k0 d| is small and the principal value is correct.
    phase = unwrap(angle(E));
    nComplex = (phase - 1i .* log(abs(E))) ./ (k0 .* dSlab);

    % guard against k0*d -> 0 at f = 0
    nComplex(k0 .* dSlab < 1e-12) = NaN;

    epsEff = nComplex ./ z;
    muEff  = nComplex .* z;

    out = struct('f', f, 'eps', epsEff, 'mu', muEff, 'n', nComplex, 'z', z);
end
