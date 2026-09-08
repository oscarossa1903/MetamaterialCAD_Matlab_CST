function [Cpul, eps_eff] = coplanarStripCpul(c, d, er, h)
%COPLANARSTRIPCPUL  Per-unit-length capacitance between the two SRR rings.
%
%   Cpul = coplanarStripCpul(c, d, er, h) models the fringing coupling between
%   the two concentric rings as a coplanar-strip (CPS) line: two strips of
%   width c separated by a slot of width d, printed on a substrate of relative
%   permittivity er and thickness h. Result is in F/m.
%
%   INPUTS (metres)
%     c   - trace width of each ring
%     d   - edge-to-edge separation between the rings
%     er  - substrate relative permittivity
%     h   - substrate thickness (use inf or [] for a strip in free space)
%
%   Model
%     k  = d / (d + 2c),  k' = sqrt(1 - k^2)
%     Cpul = eps0 * eps_eff * K(k') / K(k)
%   with a partial-capacitance estimate of eps_eff that accounts for the
%   finite substrate height (Wen / Gupta CPS filling factor). For h -> inf
%   this reduces to eps_eff = (er + 1) / 2, the value used by Marques and
%   Baena.
%
%   References
%     R. Marques, F. Martin, M. Sorolla, "Metamaterials with Negative
%       Parameters," Wiley 2007, Ch. 3.
%     K. C. Gupta et al., "Microstrip Lines and Slotlines," Artech House.

    eps0 = 8.8541878128e-12;

    if nargin < 4 || isempty(h)
        h = inf;
    end

    c = max(c, 1e-9);
    d = max(d, 1e-9);

    % --- air-filled CPS geometry ratio ------------------------------------
    k0  = d / (d + 2*c);
    Rk0 = ellipticKratio(k0);          % K(k0)/K(k0')
    R0  = 1 / Rk0;                     % K(k0')/K(k0)

    % --- substrate filling factor ---------------------------------------
    if isfinite(h)
        k1  = tanh(pi * d / (4*h)) / tanh(pi * (d + 2*c) / (4*h));
        k1  = max(min(k1, 1 - 1e-12), 1e-12);
        R1  = 1 / ellipticKratio(k1);  % K(k1')/K(k1)
        q   = 0.5 * R1 / R0;           % partial filling factor (0..1)
        eps_eff = 1 + q * (er - 1);
    else
        eps_eff = (er + 1) / 2;
    end

    Cpul = eps0 * eps_eff * R0;
end
