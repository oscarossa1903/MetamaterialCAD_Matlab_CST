function [epsEff, muEff, info] = effectiveMediumLorentz(f, s1, params, opts)
%EFFECTIVEMEDIUMLORENTZ  Stage 2a - dispersive eps_eff(f) / mu_eff(f) of the
%                        SRR (magnetic) or CSRR (electric) array.
%
%   [epsEff, muEff, info] = effectiveMediumLorentz(f, s1, params, opts)
%
%   f       - frequency vector [Hz]
%   s1      - struct from SRRLCMODEL (needs .f0, .mode, .er, and radii)
%   params  - GUI params (for the unit-cell period / filling factor)
%   opts    - optional struct: .Q (quality factor, default 40),
%                              .F (override filling factor)
%
%   Convention: exp(-i w t). Passive media have Im(eps) >= 0, Im(mu) >= 0.
%
%   SRR : mu(w) = 1 - F w^2 / (w^2 - w0^2 + i w Gamma),  eps = er_host
%   CSRR: eps(w) = er_host * [1 - F w^2 / (w^2 - w0^2 + i w Gamma)],  mu = 1
%
%   Reference: J. B. Pendry et al., IEEE T-MTT 47(11), 1999;
%              R. Marques et al., "Metamaterials with Negative Parameters".

    if nargin < 4; opts = struct(); end
    Q = getdef(opts, 'Q', 40);

    f  = f(:);
    w  = 2*pi*f;
    w0 = 2*pi*s1.f0;
    Gamma = w0 / max(Q, 1e-3);

    % ---- filling factor F = inclusion area / unit-cell area -------------
    if isfield(opts, 'F') && ~isempty(opts.F)
        F = opts.F;
    else
        if isfield(s1, 'footprint') && s1.footprint > 0
            aIncl = s1.footprint;
        elseif strcmpi(s1.shape, 'square')
            aIncl = (2*s1.rOuter)^2;
        else
            aIncl = pi * s1.rOuter^2;
        end
        [px, py] = cellPeriod(params);          % metres
        F = aIncl / (px * py);
    end
    F = min(max(F, 1e-3), 0.95);

    % ---- Lorentzian ------------------------------------------------
    chi = -F .* w.^2 ./ (w.^2 - w0^2 + 1i .* w .* Gamma);

    erHost = s1.er * (1 + 1i*getdef(opts, 'tand', 0.02));

    if strcmpi(s1.mode, 'CSRR')
        epsEff = erHost .* (1 + chi);
        muEff  = ones(size(f));
    else
        muEff  = 1 + chi;
        epsEff = erHost .* ones(size(f));
    end

    info = struct('F', F, 'Q', Q, 'Gamma', Gamma, 'w0', w0);
end

% ----------------------------------------------------------------------
function [px, py] = cellPeriod(params)
    if isfield(params, 'dx') && isfield(params, 'dy') && ...
       ~isempty(params.dx) && ~isempty(params.dy) && ...
       isfield(params, 'structure') && strcmpi(params.structure, 'array')
        px = params.dx * 1e-3;
        py = params.dy * 1e-3;
    elseif isfield(params, 'substrateSize') && ~isempty(params.substrateSize)
        px = params.substrateSize * 1e-3;
        py = px;
    else
        px = 10e-3; py = 10e-3;
    end
end

function v = getdef(s, f, d)
    if isfield(s, f) && ~isempty(s.(f)); v = s.(f); else; v = d; end
end
