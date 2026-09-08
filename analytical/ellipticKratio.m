function r = ellipticKratio(k)
%ELLIPTICKRATIO  Ratio K(k)/K(k') of complete elliptic integrals of the 1st kind.
%
%   r = ellipticKratio(k) returns K(k) / K(sqrt(1-k^2)) using Hilberg's
%   closed-form approximation (relative error < 3e-6 over 0 <= k <= 1). This
%   avoids a dependency on the Symbolic Math / specfun ELLIPKE for the
%   coplanar-strip capacitance formulas.
%
%   Reference: W. Hilberg, "From approximations to exact relations for
%   characteristic impedances," IEEE Trans. MTT, 1969.

    k = max(min(k, 1 - 1e-12), 1e-12);

    if k <= 1/sqrt(2)
        kp = sqrt(1 - k.^2);
        r  = pi ./ log(2 * (1 + sqrt(kp)) ./ (1 - sqrt(kp)));
    else
        r  = log(2 * (1 + sqrt(k)) ./ (1 - sqrt(k))) / pi;
    end
end
