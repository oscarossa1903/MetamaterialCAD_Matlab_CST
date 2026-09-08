function [S11, S21] = slabSParameters(f, epsEff, muEff, dSlab)
%SLABSPARAMETERS  S-parameters of a homogeneous slab at normal incidence.
%
%   [S11, S21] = slabSParameters(f, epsEff, muEff, dSlab)
%
%   f       - frequency vector [Hz]
%   epsEff  - complex relative permittivity (scalar or vector over f)
%   muEff   - complex relative permeability (scalar or vector over f)
%   dSlab   - slab thickness / unit-cell period along propagation [m]
%
%   Convention exp(-i w t); passive media have Im(eps),Im(mu) >= 0. The
%   reference planes sit on the two slab faces (this is what NRWRETRIEVAL
%   inverts, and matches CST's de-embedded unit-cell S-parameters).
%
%   Airy / Fresnel form (Chen et al., PRE 70, 016608, 2004):
%     n = sqrt(eps*mu),  z = sqrt(mu/eps),  R = (z-1)/(z+1),  P = exp(i n k0 d)
%     S21 = (1 - R^2) P    / (1 - R^2 P^2)
%     S11 =  R (1 - P^2)   / (1 - R^2 P^2)

    f = f(:);
    epsEff = epsEff(:) .* ones(size(f));
    muEff  = muEff(:)  .* ones(size(f));

    c0 = 299792458;
    k0 = 2*pi*f / c0;

    n = sqrt(epsEff .* muEff);
    n(imag(n) < 0) = -n(imag(n) < 0);          % passive: Im(n) >= 0

    z = sqrt(muEff ./ epsEff);
    z(real(z) < 0) = -z(real(z) < 0);          % passive: Re(z) >= 0

    P = exp(1i .* n .* k0 .* dSlab);
    R = (z - 1) ./ (z + 1);

    den = 1 - R.^2 .* P.^2;
    S21 = (1 - R.^2) .* P    ./ den;
    S11 =  R .* (1 - P.^2)   ./ den;
end
