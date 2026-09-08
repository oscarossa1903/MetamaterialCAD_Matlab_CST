function results = runAnalyticalPipeline(geom, params, opts)
%RUNANALYTICALPIPELINE  Two-stage analytical predictor for an SRR/CSRR design.
%
%   results = runAnalyticalPipeline(geom, params, opts)
%
%   Stage 1  (SRRLCMODEL)                geometry -> L, C, f0
%   Stage 2a (EFFECTIVEMEDIUMLORENTZ +   L, C     -> eps_eff(f), mu_eff(f)
%             SLABSPARAMETERS +                   -> slab S11/S21
%             NRWRETRIEVAL)                       -> retrieved eps/mu (round trip)
%   Stage 2b (LINELOADEDSPARAMETERS)     L, C     -> line-coupled S21 notch
%
%   INPUTS
%     geom   - BUILDMETAMATERIAL output (cell array of ring structs, mm)
%     params - GUI parameter struct
%     opts   - optional struct:
%                .fmin, .fmax   frequency limits [Hz]   (default 2e9, 12e9)
%                .nf            number of points         (default 801)
%                .Q             resonator quality factor (default 40)
%                .model         'slab' | 'line' | 'both' (default 'both')
%                .dSlab         retrieval thickness [m]  (default substrate h)
%                .s2pFile       CST Touchstone file to overlay (optional)
%                .axS, .axEM    uiaxes handles for plotting (optional)
%
%   OUTPUT struct `results` with fields s1, f, epsA, muA, slab, line, cst,
%   and summary (.f0_stage1, .fneg, .bwNeg).

    if nargin < 3; opts = struct(); end

    nf    = getdef(opts, 'nf', 801);
    model = lower(getdef(opts, 'model', 'both'));

    % ================================================================
    % STAGE 1
    % ================================================================
    s1 = srrLcModel(geom, params);

    % frequency grid - default to a window centred on the predicted f0
    fmin = getdef(opts, 'fmin', max(0.4 * s1.f0, 0.1e9));
    fmax = getdef(opts, 'fmax', 3.0 * s1.f0);
    if fmax <= fmin; fmax = fmin + 1e9; end

    f = linspace(fmin, fmax, nf).';

    % ================================================================
    % STAGE 2a - effective medium + slab + retrieval
    % ================================================================
    emOpts = struct('Q', getdef(opts, 'Q', 40), ...
                    'tand', getdef(opts, 'tand', 0.02));
    [epsA, muA, emInfo] = effectiveMediumLorentz(f, s1, params, emOpts);

    dSlab = getdef(opts, 'dSlab', ...
                   getdef(params, 'substrateThickness', 1.6) * 1e-3);

    slab = struct();
    if any(strcmp(model, {'slab', 'both'}))
        [slab.S11, slab.S21] = slabSParameters(f, epsA, muA, dSlab);
        r = nrwRetrieval(f, slab.S11, slab.S21, dSlab);
        slab.epsRet = r.eps; slab.muRet = r.mu; slab.n = r.n; slab.z = r.z;
    end

    % ================================================================
    % STAGE 2b - transmission-line-coupled
    % ================================================================
    line = struct();
    if any(strcmp(model, {'line', 'both'}))
        lnOpts = struct('Q', getdef(opts, 'Qline', 60), ...
                        'coupling', getdef(opts, 'coupling', 1));
        [line.S11, line.S21, line.info] = lineLoadedSParameters(f, s1, lnOpts);
    end

    % ================================================================
    % OPTIONAL - CST Touchstone overlay
    % ================================================================
    cst = struct();
    if isfield(opts, 's2pFile') && ~isempty(opts.s2pFile) && isfile(opts.s2pFile)
        ts = readTouchstone(opts.s2pFile);
        cst.f   = ts.f;
        S11c = squeeze(ts.S(1,1,:));
        S21c = squeeze(ts.S(2,1,:));
        rc = nrwRetrieval(ts.f, S11c, S21c, dSlab);
        cst.S11 = S11c; cst.S21 = S21c;
        cst.eps = rc.eps; cst.mu = rc.mu;
    end

    % ================================================================
    % SUMMARY
    % ================================================================
    if strcmpi(s1.mode, 'CSRR'); qty = real(epsA); else; qty = real(muA); end
    neg = qty < 0;
    summary = struct('f0_stage1', s1.f0, 'F', emInfo.F, ...
                     'fnegLow', firstcross(f, neg, true), ...
                     'fnegHigh', firstcross(f, neg, false), ...
                     'bwNeg', sum(neg) / nf * (fmax - fmin));

    results = struct('s1', s1, 'f', f, 'epsA', epsA, 'muA', muA, ...
                     'slab', slab, 'line', line, 'cst', cst, ...
                     'dSlab', dSlab, 'summary', summary);

    % ================================================================
    % PLOTTING
    % ================================================================
    if isfield(opts, 'axS') && ~isempty(opts.axS) && isgraphics(opts.axS)
        plotS(opts.axS, f, slab, line, cst, s1);
    end
    if isfield(opts, 'axEM') && ~isempty(opts.axEM) && isgraphics(opts.axEM)
        plotEM(opts.axEM, f, epsA, muA, slab, cst, s1);
    end
end

% ======================================================================
function plotS(ax, f, slab, line, cst, s1)
    cla(ax); hold(ax, 'on');
    g = f/1e9;
    leg = {};
    if isfield(slab, 'S21')
        plot(ax, g, 20*log10(abs(slab.S21)), 'LineWidth', 1.6, 'Color', [0.15 0.45 0.85]);
        plot(ax, g, 20*log10(abs(slab.S11)), 'LineWidth', 1.0, 'Color', [0.15 0.45 0.85 ], 'LineStyle', ':');
        leg = [leg, {'|S21| slab', '|S11| slab'}];
    end
    if isfield(line, 'S21')
        plot(ax, g, 20*log10(abs(line.S21)), 'LineWidth', 1.6, 'Color', [0.85 0.35 0.15]);
        leg = [leg, {'|S21| line'}];
    end
    if isfield(cst, 'S21')
        plot(ax, cst.f/1e9, 20*log10(abs(cst.S21)), 'k--', 'LineWidth', 1.2);
        leg = [leg, {'|S21| CST'}];
    end
    xline(ax, s1.f0/1e9, 'Color', [0.4 0.4 0.4], 'Label', 'f_0');
    grid(ax, 'on'); xlabel(ax, 'Frequency (GHz)'); ylabel(ax, 'Magnitude (dB)');
    title(ax, 'Stage 2 - S-parameters');
    ylim(ax, [-40 3]);
    if ~isempty(leg); legend(ax, leg, 'Location', 'southwest', 'FontSize', 8); end
    hold(ax, 'off');
end

% ----------------------------------------------------------------------
function plotEM(ax, f, epsA, muA, slab, cst, s1)
    cla(ax); hold(ax, 'on');
    g = f/1e9;
    if strcmpi(s1.mode, 'CSRR')
        plot(ax, g, real(epsA), 'LineWidth', 1.6, 'Color', [0.15 0.45 0.85]);
        lg = {'Re \epsilon_{eff} (model)'};
        if isfield(slab, 'epsRet')
            plot(ax, g, real(slab.epsRet), ':', 'LineWidth', 1.2, 'Color', [0.15 0.45 0.85]);
            lg = [lg, {'Re \epsilon_{eff} (retrieved)'}];
        end
        if isfield(cst, 'eps')
            plot(ax, cst.f/1e9, real(cst.eps), 'k--', 'LineWidth', 1.2);
            lg = [lg, {'Re \epsilon_{eff} (CST)'}];
        end
    else
        plot(ax, g, real(muA), 'LineWidth', 1.6, 'Color', [0.85 0.35 0.15]);
        lg = {'Re \mu_{eff} (model)'};
        if isfield(slab, 'muRet')
            plot(ax, g, real(slab.muRet), ':', 'LineWidth', 1.2, 'Color', [0.85 0.35 0.15]);
            lg = [lg, {'Re \mu_{eff} (retrieved)'}];
        end
        if isfield(cst, 'mu')
            plot(ax, cst.f/1e9, real(cst.mu), 'k--', 'LineWidth', 1.2);
            lg = [lg, {'Re \mu_{eff} (CST)'}];
        end
    end
    yline(ax, 0, 'Color', [0.5 0.5 0.5]);
    xline(ax, s1.f0/1e9, 'Color', [0.4 0.4 0.4], 'Label', 'f_0');
    grid(ax, 'on'); xlabel(ax, 'Frequency (GHz)'); ylabel(ax, 'Effective parameter');
    title(ax, 'Stage 2 - effective medium');
    legend(ax, lg, 'Location', 'best', 'FontSize', 8);
    hold(ax, 'off');
end

% ----------------------------------------------------------------------
function fc = firstcross(f, mask, wantFirst)
    idx = find(mask);
    if isempty(idx); fc = NaN; return; end
    if wantFirst; fc = f(idx(1)); else; fc = f(idx(end)); end
end

function v = getdef(s, fld, d)
    if isfield(s, fld) && ~isempty(s.(fld)); v = s.(fld); else; v = d; end
end
