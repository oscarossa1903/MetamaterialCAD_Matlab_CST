function exportMetamaterialToAntennaCST(geom,params)
%EXPORTMETAMATERIALTOANTENNACST Insert the metamaterial conductor
% (single cell or array) into an existing antenna CST project.
%
% Every export creates its own CST component and curve folder:
%
%   Component:     MM_yyyymmdd_HHMMSS
%   Curve folder:  MMCurves_yyyymmdd_HHMMSS
%
% so shape names never collide with previous exports or with the
% antenna itself. Inside each export the shapes are numbered
% Outer_001, Outer_002, ... (one per ring of every array cell).
% To remove one export in CST, delete its component.

    if ~isfield(params,'antennaCSTFile') || isempty(params.antennaCSTFile)
        error('No antenna CST project was selected.');
    end

    if ~isfile(params.antennaCSTFile)
        error('The selected antenna CST project does not exist.');
    end

    if ~isfield(params,'antennaZ')
        params.antennaZ = 0;
    end

    if isempty(geom)
        error('There is no metamaterial geometry to export.');
    end

    % ============================================================
    % UNIQUE NAMES FOR THIS EXPORT
    % ============================================================
    exportTag   = datestr(now,'yyyymmdd_HHMMSS');
    component   = ['MM_' exportTag];
    curveFolder = ['MMCurves_' exportTag];

    % ============================================================
    % OPEN CST AND EXISTING ANTENNA PROJECT
    % ============================================================
    cst = actxserver('CSTStudio.Application');

    mws = [];

    try
        mws = invoke(cst,'OpenFile',params.antennaCSTFile);
    catch
        % Some CST COM versions open the file without returning the
        % project object. In that case, recover the active 3D project.
        invoke(cst,'OpenFile',params.antennaCSTFile);
    end

    if isempty(mws)
        pause(0.5);

        try
            mws = get(cst,'Active3D');
        catch
            try
                mws = invoke(cst,'Active3D');
            catch
                error(['CST opened the application but MATLAB could not ' ...
                       'obtain the active 3D antenna project.']);
            end
        end
    end


    % ============================================================
    % CONDUCTOR MATERIAL
    %
    % If the material already exists in the antenna project, CST may
    % reject a duplicate creation. That is harmless, so continue.
    % ============================================================
    try
        conductorCode = buildCSTMaterial(params.conductorMaterial);

        invoke(mws, ...
            'AddToHistory', ...
            ['Create/Ensure ',params.conductorMaterial], ...
            conductorCode);
    catch
        % Continue: the selected material may already exist.
    end


    % ============================================================
    % DEDICATED COMPONENT FOR THIS EXPORT
    % ============================================================
    try
        invoke(mws, ...
            'AddToHistory', ...
            ['New Component ',component], ...
            sprintf('Component.New "%s"',component));
    catch
        % Some CST versions create the component automatically.
    end


    % ============================================================
    % INSERT METAMATERIAL CONDUCTOR
    % ============================================================
    z = params.antennaZ;
    nShapes = length(geom);
    nSkipped = 0;

    for k = 1:nShapes

        g = geom{k};

        % Skip degenerate contours (fewer than 3 points)
        if numel(g.outerX) < 3 || numel(g.outerY) < 3
            nSkipped = nSkipped + 1;
            continue;
        end

        outerCurve = sprintf('Outer_%03d',k);
        innerCurve = sprintf('Inner_%03d',k);

        outerSheet = sprintf('OuterSheet_%03d',k);
        innerSheet = sprintf('InnerSheet_%03d',k);

        historyTag = sprintf('%s %03d',component,k);

        % --------------------------------------------------------
        % OUTER CURVE
        % --------------------------------------------------------
        outerCurveCmd = buildCSTCurve( ...
            g.outerX, ...
            g.outerY, ...
            z, ...
            outerCurve, ...
            curveFolder);

        invoke(mws, ...
            'AddToHistory', ...
            ['Outer Curve ',historyTag], ...
            outerCurveCmd);


        % --------------------------------------------------------
        % OUTER CONDUCTOR SHEET
        % --------------------------------------------------------
        outerSheetCmd = buildCSTSheet( ...
            outerCurve, ...
            outerSheet, ...
            params.conductorMaterial, ...
            component, ...
            curveFolder);

        invoke(mws, ...
            'AddToHistory', ...
            ['Outer Sheet ',historyTag], ...
            outerSheetCmd);


        % --------------------------------------------------------
        % INNER CUTOUT
        %
        % Some geometries (for example current SSRR representation)
        % have no inner contour.
        % --------------------------------------------------------
        if numel(g.innerX) >= 3 && numel(g.innerY) >= 3

            innerCurveCmd = buildCSTCurve( ...
                g.innerX, ...
                g.innerY, ...
                z, ...
                innerCurve, ...
                curveFolder);

            invoke(mws, ...
                'AddToHistory', ...
                ['Inner Curve ',historyTag], ...
                innerCurveCmd);

            innerSheetCmd = buildCSTSheet( ...
                innerCurve, ...
                innerSheet, ...
                'Vacuum', ...
                component, ...
                curveFolder);

            invoke(mws, ...
                'AddToHistory', ...
                ['Inner Sheet ',historyTag], ...
                innerSheetCmd);

            subtractCmd = buildCSTSubtract( ...
                outerSheet, ...
                innerSheet, ...
                component);

            invoke(mws, ...
                'AddToHistory', ...
                ['Subtract ',historyTag], ...
                subtractCmd);
        end
    end


    % ============================================================
    % FINAL VIEW
    % ============================================================
    try
        invoke(mws, ...
            'AddToHistory', ...
            'Fit Antenna + Metamaterial', ...
            'Plot.ZoomToStructure');
    catch
        % Non-critical.
    end

    fprintf(['Metamaterial conductor inserted into antenna CST project.\n' ...
             '  Component: %s  |  shapes: %d  |  skipped: %d\n'], ...
             component, nShapes - nSkipped, nSkipped);
end
