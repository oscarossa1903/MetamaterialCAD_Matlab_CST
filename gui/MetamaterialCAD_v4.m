function MetamaterialCAD_v2_AntennaGeneral()

    % ============================================================
    % ADD PROJECT DIRECTORIES
    % ============================================================
    addpath('../geometry');
    addpath('../cst');
    addpath('../analytical');

    % ============================================================
    % MAIN WINDOW
    % ============================================================
    fig = uifigure( ...
        'Name','Metamaterial CAD Ultimate — MATLAB to CST', ...
        'Position',[40 40 1700 950], ...
        'Color',[0.965 0.97 0.98]);

    % ============================================================
    % AXES
    % ============================================================
    ax = uiaxes(fig, ...
        'Position',[465 180 900 690], ...
        'Box','on', ...
        'FontName','Segoe UI', ...
        'FontSize',11);

    axis(ax,'equal');
    grid(ax,'on');
    hold(ax,'on');

    title(ax,'Metamaterial Preview');


    % ============================================================
    % PREMIUM HEADER / COMMAND BAR
    % ============================================================
    headerPanel = uipanel(fig, ...
        'Position',[0 895 1700 55], ...
        'BorderType','none', ...
        'BackgroundColor',[0.08 0.12 0.20]);

    uilabel(headerPanel, ...
        'Text','METAMATERIAL CAD', ...
        'FontName','Segoe UI', ...
        'FontSize',20, ...
        'FontWeight','bold', ...
        'FontColor',[1 1 1], ...
        'Position',[20 12 240 30]);

    uilabel(headerPanel, ...
        'Text','ULTIMATE', ...
        'FontName','Segoe UI', ...
        'FontSize',11, ...
        'FontWeight','bold', ...
        'FontColor',[0.35 0.85 1.00], ...
        'Position',[255 17 100 22]);

    projectStatus = uilabel(headerPanel, ...
        'Text','●  READY', ...
        'FontName','Segoe UI', ...
        'FontSize',11, ...
        'FontWeight','bold', ...
        'FontColor',[0.35 1.00 0.60], ...
        'Position',[360 17 120 22]);

    uibutton(headerPanel, ...
        'Text','Reset View', ...
        'Position',[1280 11 110 32], ...
        'ButtonPushedFcn',@(~,~) resetPreview());

    uibutton(headerPanel, ...
        'Text','Save Design', ...
        'Position',[1400 11 110 32], ...
        'ButtonPushedFcn',@(~,~) saveCurrentDesign());

    uibutton(headerPanel, ...
        'Text','Export to CST', ...
        'FontWeight','bold', ...
        'Position',[1520 11 150 32], ...
        'ButtonPushedFcn',@(~,~) exportCurrentDesign());


    % ============================================================
    % LEFT-SIDE PROFESSIONAL WORKSPACE
    % ============================================================
    leftTabs = uitabgroup(fig, ...
        'Position',[15 90 430 790]);

    designTab = uitab(leftTabs, ...
        'Title','Design');

    materialsTab = uitab(leftTabs, ...
        'Title','Materials');

    boundariesTab = uitab(leftTabs, ...
        'Title','Boundaries');



    antennaTab = uitab(leftTabs, ...
        'Title','Antenna');


    % ============================================================
    % DESIGN TAB — METAMATERIAL TYPE
    % ============================================================
    Meta_type_Panel = uipanel(designTab, ...
        'Title','Metamaterial Type', ...
        'Position',[10 595 395 165]);

    uilabel(Meta_type_Panel, ...
        'Text','Geometry', ...
        'FontWeight','bold', ...
        'Position',[20 105 100 22]);

    geometryDrop = uidropdown(Meta_type_Panel, ...
        'Position',[140 105 225 22], ...
        'Items',{'Gielis','Square SRR'}, ...
        'Value','Gielis');

    uilabel(Meta_type_Panel, ...
        'Text','Mode', ...
        'FontWeight','bold', ...
        'Position',[20 65 100 22]);

    modeDrop = uidropdown(Meta_type_Panel, ...
        'Position',[140 65 225 22], ...
        'Items',{'SRR','CSRR'}, ...
        'Value','SRR');

    uilabel(Meta_type_Panel, ...
        'Text','Structure', ...
        'FontWeight','bold', ...
        'Position',[20 25 100 22]);

    structureDrop = uidropdown(Meta_type_Panel, ...
        'Position',[140 25 225 22], ...
        'Items',{'Single','Array'}, ...
        'Value','Single');


    % ============================================================
    % DESIGN TAB — SHARED PARAMETERS
    % ============================================================
    sharedPanel = uipanel(designTab, ...
        'Title','Shared Parameters', ...
        'Position',[10 385 395 190]);

    ringsSpinner = createSpinner( ...
        sharedPanel, ...
        'Rings', ...
        2, ...
        [1 10], ...
        1, ...
        135, ...
        true);

    thicknessSpinner = createSpinner( ...
        sharedPanel, ...
        'Metal Width (mm)', ...
        0.15, ...
        [0.01 2], ...
        0.01, ...
        90);

    spacingSpinner = createSpinner( ...
        sharedPanel, ...
        'Ring Spacing (mm)', ...
        0.20, ...
        [0.01 5], ...
        0.01, ...
        35);


    % ============================================================
    % DESIGN TAB — GIELIS PARAMETERS
    % ============================================================
    gielisPanel = uipanel(designTab, ...
        'Title','Gielis Parameters', ...
        'Position',[10 75 395 290]);

    mSpinner = createSpinner( ...
        gielisPanel, ...
        'm', ...
        6, ...
        [1 20], ...
        1, ...
        225, ...
        true);

    n1Spinner = createSpinner( ...
        gielisPanel, ...
        'n1', ...
        1, ...
        [0.1 20], ...
        0.1, ...
        180);

    n2Spinner = createSpinner( ...
        gielisPanel, ...
        'n2', ...
        1, ...
        [0.1 20], ...
        0.1, ...
        135);

    n3Spinner = createSpinner( ...
        gielisPanel, ...
        'n3', ...
        1, ...
        [0.1 20], ...
        0.1, ...
        90);

    aSpinner = createSpinner( ...
        gielisPanel, ...
        'Radius', ...
        5, ...
        [1 20], ...
        0.1, ...
        45);


    

    % ============================================================
    % DESIGN TAB — SQUARE / RECTANGULAR SRR
    % ============================================================
    ssrrPanel = uipanel(designTab, ...
        'Title','Square / Rectangular SRR Parameters', ...
        'Position',[10 75 395 290], ...
        'Visible','off');

    WSpinner = createSpinner( ...
        ssrrPanel, ...
        'Width W', ...
        10, ...
        [1 50], ...
        0.1, ...
        225);

    LSpinner = createSpinner( ...
        ssrrPanel, ...
        'Length L', ...
        8, ...
        [1 50], ...
        0.1, ...
        185);

    gapSpinner = createSpinner( ...
        ssrrPanel, ...
        'Split Gap', ...
        0.5, ...
        [0.05 5], ...
        0.05, ...
        145);

    uilabel(ssrrPanel, ...
        'Text','Split Position per Ring', ...
        'FontWeight','bold', ...
        'Position',[15 105 180 22]);

    splitTable = uitable(ssrrPanel, ...
        'Position',[15 10 360 95], ...
        'ColumnName',{'Ring','Position'}, ...
        'ColumnEditable',[false true], ...
        'ColumnFormat',{ ...
            'numeric', ...
            {'Right','Top','Left','Bottom'}}, ...
        'ColumnWidth',{80 220}, ...
        'Data',{ ...
            1,'Right'; ...
            2,'Left'});


    % ============================================================
    % MATERIALS TAB — STRUCTURE PROPERTIES
    % ============================================================
    structurePropertiesPanel = uipanel(materialsTab, ...
        'Title','Structure Properties', ...
        'Position',[10 445 395 315]);

    uilabel(structurePropertiesPanel, ...
        'Text','Conductor Material', ...
        'FontWeight','bold', ...
        'Position',[20 235 140 22]);

    conductorMaterialDrop = uidropdown(structurePropertiesPanel, ...
        'Position',[165 235 205 22], ...
        'Items',{ ...
            'Copper (annealed)', ...
            'Copper (pure)'}, ...
        'Value','Copper (annealed)');

    uilabel(structurePropertiesPanel, ...
        'Text','Dielectric Material', ...
        'FontWeight','bold', ...
        'Position',[20 185 140 22]);

    dielectricMaterialDrop = uidropdown(structurePropertiesPanel, ...
        'Position',[165 185 205 22], ...
        'Items',{ ...
            'FR-4 (lossy)', ...
            'Rogers 2929 (lossy)'}, ...
        'Value','FR-4 (lossy)');

    substrateSizeSpinner = createSpinner( ...
        structurePropertiesPanel, ...
        'Substrate Size (mm)', ...
        50, ...
        [5 200], ...
        1, ...
        120);

    hSpinner = createSpinner( ...
        structurePropertiesPanel, ...
        'h (mm)', ...
        1.6, ...
        [0 10], ...
        0.1, ...
        65);

    uilabel(materialsTab, ...
        'Text',['The substrate is square, so Substrate Size controls ' ...
              'both length and width.'], ...
        'WordWrap','on', ...
        'FontAngle','italic', ...
        'Position',[25 370 360 45]);


    % ============================================================
    % BOUNDARIES TAB
    % ============================================================
    boundaryPanel = uipanel(boundariesTab, ...
        'Title','Boundary and Floquet Configuration', ...
        'Position',[10 445 395 315]);

    uilabel(boundaryPanel, ...
        'Text','Bottom', ...
        'FontWeight','bold', ...
        'Position',[20 235 110 22]);

    portDrop = uidropdown(boundaryPanel, ...
        'Position',[145 235 220 22], ...
        'Items',{'GND','Lt','Open'}, ...
        'Value','GND');

    uilabel(boundaryPanel, ...
        'Text','Zmin', ...
        'FontWeight','bold', ...
        'Position',[20 185 110 22]);

    zminDrop = uidropdown(boundaryPanel, ...
        'Position',[145 185 220 22], ...
        'Items',{'Et=0','Open','Open add space'}, ...
        'Value','Et=0');

    uilabel(boundaryPanel, ...
        'Text','Zmax', ...
        'FontWeight','bold', ...
        'Position',[20 135 110 22]);

    zmaxDrop = uidropdown(boundaryPanel, ...
        'Position',[145 135 220 22], ...
        'Items',{'Et=0','Open','Open add space'}, ...
        'Value','Open');

    floquetNumberSpinner = createSpinner( ...
        boundaryPanel, ...
        'Floquet Number', ...
        2, ...
        [1 20], ...
        1, ...
        75, ...
        true);

    uilabel(boundariesTab, ...
        'Text',{ ...
            'CST mapping:', ...
            'Et=0  → electric', ...
            'Open → open', ...
            'Open add space → expanded open'}, ...
        'FontName','Consolas', ...
        'Position',[25 315 340 90]);




    % ============================================================
    % ANTENNA TAB
    % ============================================================

    % ------------------------------------------------------------
    % Main antenna preview (same large workspace used by the
    % metamaterial preview). It is only visible in the Antenna tab.
    % ------------------------------------------------------------
    antennaAxes = uiaxes(fig, ...
        'Position',[465 180 900 690], ...
        'Box','on', ...
        'FontName','Segoe UI', ...
        'FontSize',11, ...
        'Visible','off');

    axis(antennaAxes,'equal');
    grid(antennaAxes,'on');
    hold(antennaAxes,'on');
    xlabel(antennaAxes,'x (mm)');
    ylabel(antennaAxes,'y (mm)');
    title(antennaAxes,'Antenna + Metamaterial Preview');


    % ------------------------------------------------------------
    % Files + general DXF calibration
    % ------------------------------------------------------------
    antennaFilesPanel = uipanel(antennaTab, ...
        'Title','Antenna Files / DXF Calibration', ...
        'Position',[10 565 395 195]);


    uilabel(antennaFilesPanel, ...
        'Text','CST Antenna Model', ...
        'FontWeight','bold', ...
        'Position',[15 105 135 22]);

    cstFileLabel = uilabel(antennaFilesPanel, ...
        'Text','No CST file loaded', ...
        'Interpreter','none', ...
        'Position',[15 80 250 22]);

    uibutton(antennaFilesPanel, ...
        'Text','Load .CST', ...
        'Position',[280 78 95 28], ...
        'ButtonPushedFcn',@(~,~) loadAntennaCST());

    uilabel(antennaFilesPanel, ...
        'Text','DXF Antenna Geometry', ...
        'FontWeight','bold', ...
        'Position',[15 50 155 22]);

    dxfFileLabel = uilabel(antennaFilesPanel, ...
        'Text','No DXF file loaded', ...
        'Interpreter','none', ...
        'Position',[155 50 115 22]);

    uibutton(antennaFilesPanel, ...
        'Text','Load .DXF', ...
        'Position',[280 45 95 28], ...
        'ButtonPushedFcn',@(~,~) loadAntennaDXF());


    % ------------------------------------------------------------
    % Position / scale / rotation controls
    % ------------------------------------------------------------
    antennaTransformPanel = uipanel(antennaTab, ...
        'Title','Metamaterial Placement', ...
        'Position',[10 300 395 245]);

    antennaXSpinner = createAntennaSpinner( ...
        antennaTransformPanel,'X offset (mm)',0,[-500 500],0.1,195);

    antennaYSpinner = createAntennaSpinner( ...
        antennaTransformPanel,'Y offset (mm)',0,[-500 500],0.1,160);

    antennaRotationSpinner = createAntennaSpinner( ...
        antennaTransformPanel,'Rotation (deg)',0,[-180 180],1,125);

    antennaScaleSpinner = createAntennaSpinner( ...
        antennaTransformPanel,'Scale',1,[0.05 20],0.05,90);

    antennaZSpinner = createAntennaSpinner( ...
        antennaTransformPanel,'CST Z plane (mm)',0,[-100 100],0.1,55);

    uibutton(antennaTransformPanel, ...
        'Text','Center', ...
        'Position',[15 15 105 30], ...
        'ButtonPushedFcn',@(~,~) centerMetamaterialOnAntenna());

    uibutton(antennaTransformPanel, ...
        'Text','Fit 80%', ...
        'Position',[140 15 105 30], ...
        'ButtonPushedFcn',@(~,~) fitMetamaterialToAntenna());

    uibutton(antennaTransformPanel, ...
        'Text','Reset', ...
        'Position',[265 15 105 30], ...
        'ButtonPushedFcn',@(~,~) resetAntennaTransform());


    % ------------------------------------------------------------
    % Overlay / export
    % ------------------------------------------------------------
    antennaActionPanel = uipanel(antennaTab, ...
        'Title','Overlay and Export', ...
        'Position',[10 110 395 170]);

    overlayMetamaterialCheck = uicheckbox(antennaActionPanel, ...
        'Text','Show current metamaterial conductor', ...
        'Value',true, ...
        'Position',[15 115 280 22], ...
        'ValueChangedFcn',@(~,~) renderAntennaPreview());

    uilabel(antennaActionPanel, ...
        'Text',['Antenna mode inserts only the transformed conductor. ' ...
                'It does not create the metamaterial substrate or GND.'], ...
        'WordWrap','on', ...
        'FontAngle','italic', ...
        'Position',[15 62 360 45]);

    uibutton(antennaActionPanel, ...
        'Text','Refresh Preview', ...
        'Position',[15 18 110 32], ...
        'ButtonPushedFcn',@(~,~) renderAntennaPreview());

    uibutton(antennaActionPanel, ...
        'Text','Export Overlay to Loaded CST', ...
        'FontWeight','bold', ...
        'Position',[145 18 225 32], ...
        'ButtonPushedFcn',@(~,~) exportOverlayToAntennaCST());

    antennaStatusLabel = uilabel(antennaTab, ...
        'Text','Load a DXF to preview the antenna. Load a CST project to export the overlay.', ...
        'WordWrap','on', ...
        'FontWeight','bold', ...
        'Position',[20 40 370 55]);


    % ============================================================
    % ANALYTICAL REAL-TIME HUD
    % ============================================================
    hudPanel = uipanel(fig, ...
        'Title','Analytical First-Guess Engine', ...
        'FontWeight','bold', ...
        'Position',[465 20 900 130]);

    f0Label = uilabel(hudPanel, ...
        'Text','Estimated Resonance (f0): -- GHz', ...
        'FontWeight','bold', ...
        'FontSize',15, ...
        'Position',[20 72 430 28]);

    lLabel = uilabel(hudPanel, ...
        'Text','Effective Inductance (L): -- nH', ...
        'Position',[20 36 320 22]);

    cLabel = uilabel(hudPanel, ...
        'Text','Effective Capacitance (C): -- pF', ...
        'Position',[350 36 320 22]);

    estimatorBadge = uilabel(hudPanel, ...
        'Text','PEEC + Babinet', ...
        'HorizontalAlignment','center', ...
        'FontWeight','bold', ...
        'BackgroundColor',[0.90 0.94 1.00], ...
        'Position',[700 55 165 30]);


    % ============================================================
    % LIVE DESIGN INSPECTOR
    % ============================================================
    inspectorPanel = uipanel(fig, ...
        'Title','Live Design Inspector', ...
        'FontWeight','bold', ...
        'Position',[1380 420 300 450]);

    summaryGeometry = createInspectorRow(inspectorPanel,'Geometry','--',380);
    summaryMode = createInspectorRow(inspectorPanel,'Mode','--',340);
    summaryStructure = createInspectorRow(inspectorPanel,'Structure','--',300);
    summarySubstrate = createInspectorRow(inspectorPanel,'Substrate','--',260);
    summaryConductor = createInspectorRow(inspectorPanel,'Conductor','--',220);
    summaryDielectric = createInspectorRow(inspectorPanel,'Dielectric','--',180);
    summaryZmin = createInspectorRow(inspectorPanel,'Zmin','--',140);
    summaryZmax = createInspectorRow(inspectorPanel,'Zmax','--',100);
    summaryFloquet = createInspectorRow(inspectorPanel,'Floquet modes','--',60);

    validationLabel = uilabel(inspectorPanel, ...
        'Text','Design validation pending', ...
        'WordWrap','on', ...
        'FontWeight','bold', ...
        'HorizontalAlignment','center', ...
        'BackgroundColor',[0.94 0.95 0.97], ...
        'Position',[15 10 270 36]);


    % ============================================================
    % PREVIEW CONTROLS / ACTIVITY
    % ============================================================
    activityPanel = uipanel(fig, ...
        'Title','Workspace', ...
        'FontWeight','bold', ...
        'Position',[1380 180 300 220]);

    uibutton(activityPanel, ...
        'Text','Fit Structure', ...
        'Position',[20 150 120 32], ...
        'ButtonPushedFcn',@(~,~) resetPreview());

    uibutton(activityPanel, ...
        'Text','Refresh Preview', ...
        'Position',[155 150 125 32], ...
        'ButtonPushedFcn',@(~,~) updatePlot());

    showGridCheck = uicheckbox(activityPanel, ...
        'Text','Show grid', ...
        'Value',true, ...
        'Position',[20 105 120 22], ...
        'ValueChangedFcn',@(~,~) toggleGrid());

    showSubstrateCheck = uicheckbox(activityPanel, ...
        'Text','Show substrate', ...
        'Value',true, ...
        'Position',[155 105 125 22], ...
        'ValueChangedFcn',@(~,~) updatePlot());

    activityLabel = uilabel(activityPanel, ...
        'Text','Ready. Modify any parameter to update the preview.', ...
        'WordWrap','on', ...
        'FontName','Consolas', ...
        'BackgroundColor',[0.97 0.97 0.98], ...
        'Position',[20 25 260 55]);


    % ============================================================
    % STATUS BAR
    % ============================================================
    statusPanel = uipanel(fig, ...
        'Position',[1380 20 300 130], ...
        'BorderType','line', ...
        'BackgroundColor',[0.985 0.985 0.99]);

    uilabel(statusPanel, ...
        'Text','SYSTEM STATUS', ...
        'FontSize',10, ...
        'FontWeight','bold', ...
        'FontColor',[0.35 0.40 0.48], ...
        'Position',[15 92 150 20]);

    statusLabel = uilabel(statusPanel, ...
        'Text','Ready', ...
        'FontSize',14, ...
        'FontWeight','bold', ...
        'Position',[15 60 260 25]);

    lastActionLabel = uilabel(statusPanel, ...
        'Text','No export performed yet.', ...
        'WordWrap','on', ...
        'Position',[15 15 270 38]);


    % ============================================================
    % ANTENNA DATA
    % ============================================================
    antennaCSTPath = '';
    antennaDXFPath = '';

    % Raw DXF geometry after unit conversion to millimeters.
    % This data is never modified by preview calibration.
    antennaDXFRawEntities = {};

    % Geometry used only by the antenna preview.
    antennaDXFEntities = {};

    antennaDXFUnitScale = 1.0;
    antennaDXFCalibrationScale = 1.0;
    antennaDXFDetectedUnit = 'unknown';


    % ============================================================
    % CALLBACKS
    % ============================================================
    geometryDrop.ValueChangedFcn = ...
        @(~,~) toggleGeometry();

    structureDrop.ValueChangedFcn = ...
        @(~,~) toggleArray();

    modeDrop.ValueChangedFcn = ...
        @(~,~) updatePlot();

    splitTable.CellEditCallback = ...
        @(~,~) updatePlot();

    leftTabs.SelectionChangedFcn = ...
        @(~,~) switchMainWorkspace();

    conductorMaterialDrop.ValueChangedFcn = @(~,~) updatePlot();
    dielectricMaterialDrop.ValueChangedFcn = @(~,~) updatePlot();
    portDrop.ValueChangedFcn = @(~,~) updatePlot();
    zminDrop.ValueChangedFcn = @(~,~) updatePlot();
    zmaxDrop.ValueChangedFcn = @(~,~) updatePlot();


    % ============================================================
    % INITIALIZE SPLIT TABLE
    % ============================================================
    updateSplitTable();


    % ============================================================
    % INITIAL RENDER
    % ============================================================
    updatePlot();


    % ============================================================
    % TOGGLE GEOMETRY
    % ============================================================
    function toggleGeometry()

        gielisPanel.Visible = 'off';
        spiralPanel.Visible = 'off';
        ssrrPanel.Visible = 'off';

        switch geometryDrop.Value

            case 'Gielis'

                gielisPanel.Visible = 'on';

            case 'Spiral'

                spiralPanel.Visible = 'on';

            case 'Square SRR'

                ssrrPanel.Visible = 'on';

                % Ensure table agrees with current ring count
                updateSplitTable();
        end

        updatePlot();
    end



    % ============================================================
    % UPDATE SSRR SPLIT TABLE
    %
    % The table always contains exactly one row for every ring.
    %
    % Existing positions are preserved.
    %
    % New rings receive alternating:
    %
    % Ring 1 -> Right
    % Ring 2 -> Left
    % Ring 3 -> Right
    % Ring 4 -> Left
    % ...
    % ============================================================
    function updateSplitTable()

        N = round(ringsSpinner.Value);

        oldData = splitTable.Data;

        newData = cell(N,2);

        for k = 1:N

            newData{k,1} = k;

            % ----------------------------------------------------
            % Preserve existing selection
            % ----------------------------------------------------
            if ~isempty(oldData) && ...
               k <= size(oldData,1) && ...
               ~isempty(oldData{k,2})

                newData{k,2} = oldData{k,2};

            else

                % ------------------------------------------------
                % Default alternating split configuration
                % ------------------------------------------------
                if mod(k,2) == 1

                    newData{k,2} = 'Right';

                else

                    newData{k,2} = 'Left';
                end
            end
        end

        splitTable.Data = newData;
    end


    % ============================================================
    % COLLECT PARAMETERS
    % ============================================================
    function params = collectParams()

        % ========================================================
        % GEOMETRY TYPE
        % ========================================================
        switch geometryDrop.Value

            case 'Gielis'

                params.type = 'gielis';

            case 'Spiral'

                params.type = 'spiral';

            case 'Square SRR'

                params.type = 'ssrr';
        end


        % ========================================================
        % GENERAL PARAMETERS
        % ========================================================
        params.mode = modeDrop.Value;

        % Port and material selections
        params.portType = portDrop.Value;
        params.zminBoundary = zminDrop.Value;
        params.zmaxBoundary = zmaxDrop.Value;
        params.floquetNumber = round(floquetNumberSpinner.Value);
        params.conductorMaterial = conductorMaterialDrop.Value;
        params.dielectricMaterial = dielectricMaterialDrop.Value;

        % Antenna integration files
        params.antennaCSTFile = antennaCSTPath;
        params.antennaDXFFile = antennaDXFPath;
        params.antennaDXFUnitScale = antennaDXFUnitScale;
        params.antennaDXFCalibrationScale = antennaDXFCalibrationScale;
        params.antennaOverlayEnabled = overlayMetamaterialCheck.Value;
        params.antennaOffsetX = antennaXSpinner.Value;
        params.antennaOffsetY = antennaYSpinner.Value;
        params.antennaRotation = antennaRotationSpinner.Value;
        params.antennaScale = antennaScaleSpinner.Value;
        params.antennaZ = antennaZSpinner.Value;

        params.numRings = ringsSpinner.Value;

        params.thickness = thicknessSpinner.Value;

        params.spacing = spacingSpinner.Value;

        params.res = 1500;


        % ========================================================
        % GIELIS / SPIRAL ANGULAR GAP
        % ========================================================


        % ========================================================
        % GIELIS PARAMETERS
        % ========================================================
        params.m = mSpinner.Value;
        params.n1 = n1Spinner.Value;
        params.n2 = n2Spinner.Value;
        params.n3 = n3Spinner.Value;
        params.a = aSpinner.Value;
        
        % ========================================================
        % SSRR PARAMETERS
        % ========================================================
        params.W = WSpinner.Value;
        params.L = LSpinner.Value;
        params.gapSSRR = gapSpinner.Value;


        % ========================================================
        % INDEPENDENT SPLIT POSITION FOR EACH SSRR RING
        % ========================================================
        N = params.numRings;

        tableData = splitTable.Data;

        % Make absolutely sure table contains N rings
        if size(tableData,1) ~= N

            updateSplitTable();

            tableData = splitTable.Data;
        end

        params.gapPositions = ...
            cell(1,N);

        for k = 1:N

            params.gapPositions{k} = ...
                lower(char(tableData{k,2}));
        end


        % ========================================================
        % SUBSTRATE PARAMETERS
        % ========================================================
        params.substrateSize = ...
            substrateSizeSpinner.Value;

        params.substrateThickness = ...
            hSpinner.Value;

        params.substrateMaterial = ...
            dielectricMaterialDrop.Value;
    end


    % ============================================================
    % UPDATE PLOT
    % ============================================================
    function updatePlot()

        cla(ax);

        params = collectParams();

        updateInspector(params);
        statusLabel.Text = 'Preview updated';
        activityLabel.Text = 'Preview synchronized with current design parameters.';

        if exist('antennaAxes','var') && isvalid(antennaAxes) && ...
           leftTabs.SelectedTab == antennaTab
            renderAntennaPreview();
        end


        % ========================================================
        % GENERATE UNIT CELL
        % ========================================================
        try

            geom = ...
                buildMetamaterial(params);

        catch ME

            f0Label.Text = ...
                'Estimated Resonance (f0): Geometry Error';

            lLabel.Text = ...
                'Effective Inductance (L): -- nH';

            cLabel.Text = ...
                'Effective Capacitance (C): -- pF';

            title(ax, ...
                ['Geometry Error: ' ME.message]);

            return;
        end


        % ========================================================
        % BUILD ARRAY IF REQUESTED
        % ========================================================
        if strcmp(structureDrop.Value,'Array')

            geom = buildArray( ...
                geom, ...
                params.Nx, ...
                params.Ny, ...
                params.dx, ...
                params.dy, ...
                0, ...
                0, ...
                true);
        end


        hold(ax,'on');


        % ========================================================
        % SUBSTRATE
        % ========================================================
        substrateL = ...
            params.substrateSize;

        if showSubstrateCheck.Value
            rectangle(ax, ...
                'Position',[ ...
                    -substrateL/2, ...
                    -substrateL/2, ...
                     substrateL, ...
                     substrateL], ...
                'FaceColor',[0.88 0.90 0.94], ...
                'EdgeColor',[0.25 0.30 0.38], ...
                'LineWidth',1.2);
        end


        % ========================================================
        % CSRR GROUND
        % ========================================================
        if strcmp(params.mode,'CSRR')

            rectangle(ax, ...
                'Position',[ ...
                    -substrateL/2, ...
                    -substrateL/2, ...
                     substrateL, ...
                     substrateL], ...
                'FaceColor',[0.45 0.45 0.45], ...
                'EdgeColor','none');
        end


        % ========================================================
        % DRAW METAMATERIAL GEOMETRY
        % ========================================================
        for i = 1:length(geom)

            xo = geom{i}.outerX;
            yo = geom{i}.outerY;

            xi = geom{i}.innerX;
            yi = geom{i}.innerY;


            % ====================================================
            % SINGLE CLOSED CONDUCTOR POLYGON
            %
            % Used by SSRR
            % ====================================================
            if isempty(xi) || isempty(yi)

                X = xo(:).';
                Y = yo(:).';


            % ====================================================
            % OUTER + INNER CONTOUR
            %
            % Used by Gielis / Spiral
            % ====================================================
            else

                X = [ ...
                    xo(:).' ...
                    fliplr(xi(:).')];

                Y = [ ...
                    yo(:).' ...
                    fliplr(yi(:).')];
            end


            % ====================================================
            % SRR / CSRR PREVIEW
            % ====================================================
            if strcmp(params.mode,'SRR')

                patch(ax, ...
                    X, ...
                    Y, ...
                    [0.8 0 0], ...
                    'FaceAlpha',0.5, ...
                    'EdgeColor','r');

            else

                patch(ax, ...
                    X, ...
                    Y, ...
                    'w', ...
                    'EdgeColor','none');
            end
        end


        % ========================================================
        % MODULAR EM ESTIMATION
        % ========================================================
        if ~isempty(geom)

            try

                ring = geom{1};

                ox = ring.outerX(:);
                oy = ring.outerY(:);

                ix = ring.innerX(:);
                iy = ring.innerY(:);


                % =================================================
                % APPROXIMATE CENTERLINE
                % =================================================
                if ~isempty(ix) && ...
                   ~isempty(iy)

                    % ---------------------------------------------
                    % Gielis / Spiral
                    % ---------------------------------------------
                    nPts = min( ...
                        length(ox), ...
                        length(ix));

                    xMid = ...
                        (ox(1:nPts) + ...
                         ix(1:nPts))/2;

                    yMid = ...
                        (oy(1:nPts) + ...
                         iy(1:nPts))/2;

                else

                    % ---------------------------------------------
                    % SSRR
                    %
                    % Current SSRR representation is a single
                    % closed conductive polygon.
                    % ---------------------------------------------
                    xMid = ox;
                    yMid = oy;
                end


                % =================================================
                % REMOVE CONSECUTIVE DUPLICATE POINTS
                % =================================================
                if length(xMid) > 1

                    d = sqrt( ...
                        diff(xMid).^2 + ...
                        diff(yMid).^2);

                    keep = ...
                        [true; d > 1e-12];

                    xMid = ...
                        xMid(keep);

                    yMid = ...
                        yMid(keep);
                end


                % =================================================
                % CONVERT mm -> m
                % =================================================
                V_skeleton = ...
                    [xMid,yMid] * 1e-3;


                % =================================================
                % METAL TRACE WIDTH
                % =================================================
                w_m = ...
                    params.thickness * 1e-3;


                % =================================================
                % COPPER CLADDING THICKNESS
                % =================================================
                t_m = 35e-6;


                % =================================================
                % GAP DIMENSION
                % =================================================
                if strcmp(params.type,'ssrr')

                    % Physical SSRR gap
                    gap_m = ...
                        params.gapSSRR * 1e-3;

                else

                    % Gielis / current spiral angular gap
                    rMean_m = ...
                        mean( ...
                            sqrt( ...
                                xMid.^2 + ...
                                yMid.^2)) * 1e-3;

                    gap_m = ...
                        rMean_m * params.gap;
                end


                % =================================================
                % SUBSTRATE PERMITTIVITY
                % =================================================
                substrate_er = 4.4;


                % =================================================
                % EXECUTE ANALYTICAL SOLVER
                % =================================================
                [f_est,L_eff,C_eff] = ...
                    universal_rapid_guess( ...
                        V_skeleton, ...
                        w_m, ...
                        t_m, ...
                        gap_m, ...
                        params.mode, ...
                        substrate_er);


                % =================================================
                % UPDATE HUD
                % =================================================
                f0Label.Text = sprintf( ...
                    'Estimated Resonance (f0): %.3f GHz', ...
                    f_est/1e9);

                lLabel.Text = sprintf( ...
                    'Effective Inductance (L): %.3f nH', ...
                    L_eff*1e9);

                cLabel.Text = sprintf( ...
                    'Effective Capacitance (C): %.3f pF', ...
                    C_eff*1e12);


            catch ME

                f0Label.Text = ...
                    'Estimated Resonance (f0): Analytical Error';

                lLabel.Text = ...
                    'Effective Inductance (L): -- nH';

                cLabel.Text = ...
                    'Effective Capacitance (C): -- pF';

                fprintf( ...
                    'Analytical estimator error: %s\n', ...
                    ME.message);
            end
        end


        % ========================================================
        % AXES SETTINGS
        % ========================================================
        axis(ax,'equal');

        xlabel(ax,'x (mm)');

        ylabel(ax,'y (mm)');

        grid(ax,'on');

        title(ax,'Metamaterial Preview');
    end


    % ============================================================
    % EXPORT CURRENT DESIGN
    % ============================================================
    function exportCurrentDesign()

        params = collectParams();


        % ========================================================
        % BUILD GEOMETRY
        % ========================================================
        try

            geom = ...
                buildMetamaterial(params);

        catch ME

            uialert( ...
                fig, ...
                ME.message, ...
                'Geometry Error');

            return;
        end


        % ========================================================
        % BUILD ARRAY
        % ========================================================
        if strcmp(structureDrop.Value,'Array')

            geom = buildArray( ...
                geom, ...
                params.Nx, ...
                params.Ny, ...
                params.dx, ...
                params.dy, ...
                0, ...
                0, ...
                true);
        end


        % ========================================================
        % EXPORT TO CST
        % ========================================================
        try

            exportToCST_COM( ...
                geom, ...
                params);

            statusLabel.Text = 'Export completed';
            projectStatus.Text = '●  EXPORTED';
            lastActionLabel.Text = ...
                ['Last export: ' datestr(now,'yyyy-mm-dd HH:MM:SS')];

            uialert( ...
                fig, ...
                'CST model generated successfully.', ...
                'Export');

        catch ME

            statusLabel.Text = 'Export failed';
            projectStatus.Text = '●  ERROR';
            lastActionLabel.Text = ME.message;

            uialert( ...
                fig, ...
                ME.message, ...
                'CST Export Error');
        end
    end


    % ============================================================
    % SWITCH MAIN WORKSPACE
    % ============================================================
    function switchMainWorkspace()

        isAntenna = (leftTabs.SelectedTab == antennaTab);

        if isAntenna
            ax.Visible = 'off';
            antennaAxes.Visible = 'on';
            renderAntennaPreview();
        else
            antennaAxes.Visible = 'off';
            ax.Visible = 'on';
        end
    end


    % ============================================================
    % ANTENNA SPINNER FACTORY
    % ============================================================
    function spinner = createAntennaSpinner(parent,labelText,value,limits,step,ypos)

        uilabel(parent, ...
            'Text',labelText, ...
            'Position',[15 ypos 145 22]);

        spinner = uispinner(parent, ...
            'Position',[180 ypos 105 22], ...
            'Limits',limits, ...
            'Value',value, ...
            'Step',step);

        spinner.ValueChangedFcn = @(~,~) renderAntennaPreview();
    end


    % ============================================================
    % LOAD ANTENNA CST FILE
    % ============================================================
    function loadAntennaCST()

        [fileName,pathName] = uigetfile( ...
            {'*.cst','CST Studio Project (*.cst)'}, ...
            'Select CST antenna project');

        if isequal(fileName,0)
            return;
        end

        antennaCSTPath = fullfile(pathName,fileName);
        cstFileLabel.Text = fileName;

        antennaStatusLabel.Text = ...
            ['CST antenna project loaded: ' fileName];

        statusLabel.Text = 'Antenna CST loaded';
        lastActionLabel.Text = ['Antenna CST: ' fileName];
    end


    % ============================================================
    % LOAD ANTENNA DXF FILE
    % ============================================================
    function loadAntennaDXF()

        [fileName,pathName] = uigetfile( ...
            {'*.dxf','DXF Geometry (*.dxf)'}, ...
            'Select antenna DXF');

        if isequal(fileName,0)
            return;
        end

        antennaDXFPath = fullfile(pathName,fileName);

        try
            reloadAntennaDXF();

            dxfFileLabel.Text = fileName;

            antennaStatusLabel.Text = ...
                ['DXF loaded: ' fileName ...
                 '. Preview calibration changes only the DXF display; ' ...
                 'the metamaterial remains in real CST millimeters.'];

            statusLabel.Text = 'Antenna DXF loaded';
            lastActionLabel.Text = ['Antenna DXF: ' fileName];

            renderAntennaPreview();

        catch ME
            antennaDXFPath = '';
            antennaDXFRawEntities = {};
            antennaDXFEntities = {};
            antennaStatusLabel.Text = 'DXF load failed.';
            uialert(fig,ME.message,'DXF Import Error');
        end
    end


    % ============================================================
    % RELOAD DXF WHEN UNIT INTERPRETATION CHANGES
    % ============================================================
    function reloadAntennaDXF()

        if isempty(antennaDXFPath)
            return;
        end

        [rawEntities,autoScale,autoUnit] = ...
            readDXF2D(antennaDXFPath);

        scaleToMM = autoScale;
        unitName = autoUnit;

        antennaDXFUnitScale = scaleToMM;
        antennaDXFDetectedUnit = unitName;

        % Convert DXF coordinates to physical millimeters.
        antennaDXFRawEntities = rawEntities;

        for ii = 1:numel(antennaDXFRawEntities)

            antennaDXFRawEntities{ii}.x = ...
                antennaDXFRawEntities{ii}.x * scaleToMM;

            antennaDXFRawEntities{ii}.y = ...
                antennaDXFRawEntities{ii}.y * scaleToMM;
        end

        applyDXFCalibrationAndRefresh();
    end


    % ============================================================
    % GENERAL DXF PREVIEW CALIBRATION
    %
    % No antenna-specific geometry is reconstructed.
    % No ring widths are hard-coded.
    %
    % Modes:
    %   1:1          -> use DXF dimensions exactly as imported.
    %   Match width  -> scale whole DXF uniformly so its total
    %                   width equals Reference (mm).
    %   Match height -> scale whole DXF uniformly so its total
    %                   height equals Reference (mm).
    %
    % The calibration is performed around the DXF origin (0,0),
    % preserving relative geometry and the CST coordinate system.
    % ============================================================
    function applyDXFCalibrationAndRefresh()

        if isempty(antennaDXFRawEntities)
            antennaDXFEntities = {};
            antennaDXFCalibrationScale = 1.0;
            renderAntennaPreview();
            return;
        end

        [rawWidth,rawHeight] = entityCollectionSize( ...
            antennaDXFRawEntities);

        if rawWidth <= eps
            error('DXF width is zero; width calibration is not possible.');
        end

        % ========================================================
        % DXF PHYSICAL SCALE CORRECTION (1/2)
        %
        % In this workflow the loaded DXF coordinates represent twice
        % the intended physical dimensions. Therefore every imported
        % X/Y coordinate is divided by 2.
        %
        % Example:
        %   DXF coordinates:  -7 ... +7 mm  (14 mm total)
        %   Physical antenna: -3.5 ... +3.5 mm (7 mm total)
        %
        % This uniform factor preserves all proportions, positions and
        % relative dimensions of substrate, antenna geometry and overlay.
        % ========================================================
        antennaDXFCalibrationScale = 1;
        antennaDXFEntities = antennaDXFRawEntities;

        for ii = 1:numel(antennaDXFEntities)
            antennaDXFEntities{ii}.x = ...
                antennaDXFEntities{ii}.x * antennaDXFCalibrationScale;

            antennaDXFEntities{ii}.y = ...
                antennaDXFEntities{ii}.y * antennaDXFCalibrationScale;
        end

        [previewWidth,previewHeight] = ...
            entityCollectionSize(antennaDXFEntities);

        antennaStatusLabel.Text = sprintf( ...
            ['DXF preview | units: %s | unit factor: %.6g | ' ...
             'physical scale: %.6g | corrected size: %.3f x %.3f mm'], ...
            antennaDXFDetectedUnit, ...
            antennaDXFUnitScale, ...
            antennaDXFCalibrationScale, ...
            previewWidth, ...
            previewHeight);

        renderAntennaPreview();
    end


    % ============================================================
    % GET TOTAL WIDTH / HEIGHT OF AN ENTITY COLLECTION
    % ============================================================
    function [width,height] = entityCollectionSize(entityList)

        allX = [];
        allY = [];

        for ii = 1:numel(entityList)
            allX = [allX entityList{ii}.x(:).']; %#ok<AGROW>
            allY = [allY entityList{ii}.y(:).']; %#ok<AGROW>
        end

        allX = allX(isfinite(allX));
        allY = allY(isfinite(allY));

        if isempty(allX) || isempty(allY)
            width = 0;
            height = 0;
        else
            width = max(allX)-min(allX);
            height = max(allY)-min(allY);
        end
    end


    % ============================================================
    % GET DXF BOUNDS
    % ============================================================
    function [xmin,xmax,ymin,ymax] = getAntennaBounds()

        if isempty(antennaDXFEntities)
            xmin = -1; xmax = 1;
            ymin = -1; ymax = 1;
            return;
        end

        allX = [];
        allY = [];

        for ii = 1:numel(antennaDXFEntities)
            allX = [allX antennaDXFEntities{ii}.x]; %#ok<AGROW>
            allY = [allY antennaDXFEntities{ii}.y]; %#ok<AGROW>
        end

        xmin = min(allX);
        xmax = max(allX);
        ymin = min(allY);
        ymax = max(allY);
    end


    % ============================================================
    % CENTER METAMATERIAL ON ANTENNA
    % ============================================================
    function centerMetamaterialOnAntenna()

        if isempty(antennaDXFEntities)
            antennaXSpinner.Value = 0;
            antennaYSpinner.Value = 0;
        else
            [xmin,xmax,ymin,ymax] = getAntennaBounds();
            antennaXSpinner.Value = (xmin+xmax)/2;
            antennaYSpinner.Value = (ymin+ymax)/2;
        end

        renderAntennaPreview();
    end


    % ============================================================
    % FIT METAMATERIAL TO 80% OF ANTENNA BOUNDING BOX
    % ============================================================
    function fitMetamaterialToAntenna()

        if isempty(antennaDXFEntities)
            uialert(fig,'Load a DXF file first.','Antenna');
            return;
        end

        try
            paramsLocal = collectParams();
            baseGeom = buildMetamaterial(paramsLocal);

            if strcmp(structureDrop.Value,'Array')
                baseGeom = buildArray( ...
                    baseGeom, ...
                    paramsLocal.Nx, ...
                    paramsLocal.Ny, ...
                    paramsLocal.dx, ...
                    paramsLocal.dy, ...
                    0,0,true);
            end

            [mxmin,mxmax,mymin,mymax] = geometryBounds(baseGeom);
            [axmin,axmax,aymin,aymax] = getAntennaBounds();

            metaW = max(mxmax-mxmin,eps);
            metaH = max(mymax-mymin,eps);
            antW = max(axmax-axmin,eps);
            antH = max(aymax-aymin,eps);

            antennaScaleSpinner.Value = ...
                max(0.05,min(20,0.80*min(antW/metaW,antH/metaH)));

            antennaXSpinner.Value = (axmin+axmax)/2;
            antennaYSpinner.Value = (aymin+aymax)/2;

            renderAntennaPreview();

        catch ME
            uialert(fig,ME.message,'Fit Error');
        end
    end


    % ============================================================
    % RESET ANTENNA TRANSFORM
    % ============================================================
    function resetAntennaTransform()

        antennaXSpinner.Value = 0;
        antennaYSpinner.Value = 0;
        antennaRotationSpinner.Value = 0;
        antennaScaleSpinner.Value = 1;
        antennaZSpinner.Value = 0;

        renderAntennaPreview();
    end


    % ============================================================
    % GEOMETRY BOUNDS
    % ============================================================
    function [xmin,xmax,ymin,ymax] = geometryBounds(geomLocal)

        allX = [];
        allY = [];

        for ii = 1:numel(geomLocal)
            allX = [allX geomLocal{ii}.outerX(:).' geomLocal{ii}.innerX(:).']; %#ok<AGROW>
            allY = [allY geomLocal{ii}.outerY(:).' geomLocal{ii}.innerY(:).']; %#ok<AGROW>
        end

        allX = allX(isfinite(allX));
        allY = allY(isfinite(allY));

        if isempty(allX) || isempty(allY)
            xmin = -1; xmax = 1;
            ymin = -1; ymax = 1;
        else
            xmin = min(allX); xmax = max(allX);
            ymin = min(allY); ymax = max(allY);
        end
    end


    % ============================================================
    % APPLY ANTENNA TRANSFORM
    % ============================================================
    function transformed = transformGeometryForAntenna(geomLocal)

        transformed = geomLocal;

        s = antennaScaleSpinner.Value;
        angle = deg2rad(antennaRotationSpinner.Value);
        tx = antennaXSpinner.Value;
        ty = antennaYSpinner.Value;

        R = [cos(angle) -sin(angle); ...
             sin(angle)  cos(angle)];

        for ii = 1:numel(geomLocal)

            transformed{ii} = geomLocal{ii};

            [xo,yo] = transformXY( ...
                geomLocal{ii}.outerX, ...
                geomLocal{ii}.outerY, ...
                s,R,tx,ty);

            [xi,yi] = transformXY( ...
                geomLocal{ii}.innerX, ...
                geomLocal{ii}.innerY, ...
                s,R,tx,ty);

            transformed{ii}.outerX = xo;
            transformed{ii}.outerY = yo;
            transformed{ii}.innerX = xi;
            transformed{ii}.innerY = yi;
        end
    end


    % ============================================================
    % TRANSFORM ONE X/Y CONTOUR
    % ============================================================
    function [xOut,yOut] = transformXY(xIn,yIn,s,R,tx,ty)

        if isempty(xIn) || isempty(yIn)
            xOut = xIn;
            yOut = yIn;
            return;
        end

        originalSize = size(xIn);

        pts = [xIn(:).'; yIn(:).'];
        pts = s * pts;
        pts = R * pts;

        xOut = reshape(pts(1,:) + tx,originalSize);
        yOut = reshape(pts(2,:) + ty,originalSize);
    end


    % ============================================================
    % BUILD CURRENT METAMATERIAL FOR ANTENNA
    % ============================================================
    function metaGeom = buildCurrentAntennaMetamaterial()

        paramsLocal = collectParams();
        metaGeom = buildMetamaterial(paramsLocal);

        if strcmp(structureDrop.Value,'Array')
            metaGeom = buildArray( ...
                metaGeom, ...
                paramsLocal.Nx, ...
                paramsLocal.Ny, ...
                paramsLocal.dx, ...
                paramsLocal.dy, ...
                0, ...
                0, ...
                true);
        end

        metaGeom = transformGeometryForAntenna(metaGeom);
    end


    % ============================================================
    % ANTENNA PREVIEW
    % ============================================================
    function renderAntennaPreview()

        if ~exist('antennaAxes','var') || ~isvalid(antennaAxes)
            return;
        end

        cla(antennaAxes);
        hold(antennaAxes,'on');

        % Antenna DXF
        if ~isempty(antennaDXFEntities)
            for n = 1:numel(antennaDXFEntities)
                e = antennaDXFEntities{n};

                plot(antennaAxes, ...
                    e.x,e.y, ...
                    'LineWidth',1.25);
            end
        end

        % Metamaterial conductor only
        if overlayMetamaterialCheck.Value

            try
                metaGeom = buildCurrentAntennaMetamaterial();

                for kk = 1:length(metaGeom)

                    xo = metaGeom{kk}.outerX;
                    yo = metaGeom{kk}.outerY;
                    xi = metaGeom{kk}.innerX;
                    yi = metaGeom{kk}.innerY;

                    if isempty(xi) || isempty(yi)
                        X = xo(:).';
                        Y = yo(:).';
                    else
                        X = [xo(:).' fliplr(xi(:).')];
                        Y = [yo(:).' fliplr(yi(:).')];
                    end

                    patch(antennaAxes, ...
                        X,Y, ...
                        [0.80 0.10 0.10], ...
                        'FaceAlpha',0.32, ...
                        'EdgeColor',[0.65 0.00 0.00], ...
                        'LineWidth',1.1);
                end

            catch ME
                antennaStatusLabel.Text = ...
                    ['Metamaterial overlay error: ' ME.message];
            end
        end

        axis(antennaAxes,'equal');
        grid(antennaAxes,'on');
        xlabel(antennaAxes,'x (mm)');
        ylabel(antennaAxes,'y (mm)');
        title(antennaAxes,'Antenna + Metamaterial Preview');

        if ~isempty(antennaDXFEntities)
            axis(antennaAxes,'tight');
        else
            xlim(antennaAxes,[-25 25]);
            ylim(antennaAxes,[-25 25]);
        end
    end


    % ============================================================
    % EXPORT TRANSFORMED METAMATERIAL INTO LOADED ANTENNA CST
    % ============================================================
    function exportOverlayToAntennaCST()

        if isempty(antennaCSTPath)
            uialert(fig, ...
                'Load the antenna .cst project first.', ...
                'Antenna CST Required');
            return;
        end

        try
            transformedGeom = buildCurrentAntennaMetamaterial();
            paramsLocal = collectParams();

            exportMetamaterialToAntennaCST( ...
                transformedGeom, ...
                paramsLocal);

            statusLabel.Text = 'Antenna overlay exported';
            projectStatus.Text = '●  EXPORTED';
            lastActionLabel.Text = ...
                ['Overlay inserted into antenna CST: ' ...
                 datestr(now,'yyyy-mm-dd HH:MM:SS')];

            antennaStatusLabel.Text = ...
                'Metamaterial conductor inserted into the loaded CST antenna project.';

            uialert(fig, ...
                'Metamaterial conductor inserted into the antenna CST project.', ...
                'Antenna Export');

        catch ME
            statusLabel.Text = 'Antenna export failed';
            projectStatus.Text = '●  ERROR';
            antennaStatusLabel.Text = ME.message;

            uialert(fig,ME.message,'Antenna CST Export Error');
        end
    end


    % ============================================================
    % SIMPLE 2D ASCII DXF READER
    % ============================================================
    function [entities,unitScaleToMM,unitName] = readDXF2D(filePath)

        fid = fopen(filePath,'r');

        if fid < 0
            error('Could not open DXF file.');
        end

        cleanupObj = onCleanup(@() fclose(fid)); %#ok<NASGU>

        % --------------------------------------------------------
        % Detect binary DXF before attempting ASCII group-code read
        % --------------------------------------------------------
        firstLine = fgetl(fid);

        if ischar(firstLine) && contains(firstLine,'AutoCAD Binary DXF')
            error(['This DXF is binary. Save/export it as ASCII DXF ' ...
                   '(for example AutoCAD 2010/2013 ASCII DXF) and load it again.']);
        end

        frewind(fid);

        raw = textscan(fid,'%s', ...
            'Delimiter','\n', ...
            'Whitespace','');

        lines = raw{1};

        if mod(numel(lines),2) ~= 0
            lines{end+1} = '';
        end

        codes = strtrim(lines(1:2:end));
        values = strtrim(lines(2:2:end));

        % --------------------------------------------------------
        % Read DXF $INSUNITS from HEADER and convert to millimeters.
        %
        % Common AutoCAD INSUNITS values:
        % 0 = unitless, 1 = inch, 2 = feet, 4 = mm,
        % 5 = cm, 6 = m.
        % --------------------------------------------------------
        unitScaleToMM = 1.0;
        unitName = 'unitless / assumed mm';

        for uu = 1:numel(values)-2

            if strcmpi(values{uu},'$INSUNITS')

                unitCode = NaN;

                for vv = uu+1:min(uu+6,numel(codes))
                    if strcmp(codes{vv},'70')
                        unitCode = str2double(values{vv});
                        break;
                    end
                end

                if isfinite(unitCode)
                    [unitScaleToMM,unitName] = ...
                        dxfUnitCodeToMM(unitCode);
                end

                break;
            end
        end

        entities = {};
        detectedTypes = {};
        i = 1;

        while i <= numel(codes)

            if strcmp(codes{i},'0')

                entityType = upper(values{i});
                detectedTypes{end+1} = entityType; %#ok<AGROW>

                switch entityType

                    % ====================================================
                    % LINE
                    % ====================================================
                    case 'LINE'

                        j = i + 1;
                        x1 = NaN; y1 = NaN;
                        x2 = NaN; y2 = NaN;

                        while j <= numel(codes) && ~strcmp(codes{j},'0')

                            switch codes{j}
                                case '10'
                                    x1 = str2double(values{j});
                                case '20'
                                    y1 = str2double(values{j});
                                case '11'
                                    x2 = str2double(values{j});
                                case '21'
                                    y2 = str2double(values{j});
                            end

                            j = j + 1;
                        end

                        if all(isfinite([x1 y1 x2 y2]))
                            entities{end+1} = struct( ...
                                'type','LINE', ...
                                'x',[x1 x2], ...
                                'y',[y1 y2]); %#ok<AGROW>
                        end

                        i = j;
                        continue;


                    % ====================================================
                    % LIGHTWEIGHT POLYLINE
                    % ====================================================
                    case 'LWPOLYLINE'

                        j = i + 1;
                        x = [];
                        y = [];
                        closedFlag = false;
                        pendingX = NaN;

                        while j <= numel(codes) && ~strcmp(codes{j},'0')

                            switch codes{j}

                                case '70'
                                    flag = str2double(values{j});
                                    closedFlag = bitand(round(flag),1) == 1;

                                case '10'
                                    pendingX = str2double(values{j});

                                case '20'
                                    if isfinite(pendingX)
                                        x(end+1) = pendingX; %#ok<AGROW>
                                        y(end+1) = str2double(values{j}); %#ok<AGROW>
                                        pendingX = NaN;
                                    end
                            end

                            j = j + 1;
                        end

                        if numel(x) >= 2

                            if closedFlag && ...
                               (x(end) ~= x(1) || y(end) ~= y(1))
                                x(end+1) = x(1);
                                y(end+1) = y(1);
                            end

                            entities{end+1} = struct( ...
                                'type','LWPOLYLINE', ...
                                'x',x, ...
                                'y',y); %#ok<AGROW>
                        end

                        i = j;
                        continue;


                    % ====================================================
                    % OLD-STYLE POLYLINE + VERTEX + SEQEND
                    % ====================================================
                    case 'POLYLINE'

                        j = i + 1;
                        closedFlag = false;

                        % Read POLYLINE header
                        while j <= numel(codes) && ~strcmp(codes{j},'0')
                            if strcmp(codes{j},'70')
                                flag = str2double(values{j});
                                closedFlag = bitand(round(flag),1) == 1;
                            end
                            j = j + 1;
                        end

                        x = [];
                        y = [];

                        % Read all following VERTEX entities
                        while j <= numel(codes)

                            if strcmp(codes{j},'0') && ...
                               strcmpi(values{j},'SEQEND')
                                j = j + 1;
                                break;
                            end

                            if strcmp(codes{j},'0') && ...
                               strcmpi(values{j},'VERTEX')

                                k = j + 1;
                                xv = NaN;
                                yv = NaN;

                                while k <= numel(codes) && ...
                                      ~strcmp(codes{k},'0')

                                    switch codes{k}
                                        case '10'
                                            xv = str2double(values{k});
                                        case '20'
                                            yv = str2double(values{k});
                                    end

                                    k = k + 1;
                                end

                                if isfinite(xv) && isfinite(yv)
                                    x(end+1) = xv; %#ok<AGROW>
                                    y(end+1) = yv; %#ok<AGROW>
                                end

                                j = k;
                            else
                                j = j + 1;
                            end
                        end

                        if numel(x) >= 2

                            if closedFlag && ...
                               (x(end) ~= x(1) || y(end) ~= y(1))
                                x(end+1) = x(1);
                                y(end+1) = y(1);
                            end

                            entities{end+1} = struct( ...
                                'type','POLYLINE', ...
                                'x',x, ...
                                'y',y); %#ok<AGROW>
                        end

                        i = j;
                        continue;


                    % ====================================================
                    % CIRCLE
                    % ====================================================
                    case 'CIRCLE'

                        j = i + 1;
                        xc = NaN; yc = NaN; r = NaN;

                        while j <= numel(codes) && ~strcmp(codes{j},'0')

                            switch codes{j}
                                case '10'
                                    xc = str2double(values{j});
                                case '20'
                                    yc = str2double(values{j});
                                case '40'
                                    r = str2double(values{j});
                            end

                            j = j + 1;
                        end

                        if all(isfinite([xc yc r]))
                            th = linspace(0,2*pi,181);

                            entities{end+1} = struct( ...
                                'type','CIRCLE', ...
                                'x',xc + r*cos(th), ...
                                'y',yc + r*sin(th)); %#ok<AGROW>
                        end

                        i = j;
                        continue;


                    % ====================================================
                    % ARC
                    % ====================================================
                    case 'ARC'

                        j = i + 1;
                        xc = NaN; yc = NaN; r = NaN;
                        a1 = NaN; a2 = NaN;

                        while j <= numel(codes) && ~strcmp(codes{j},'0')

                            switch codes{j}
                                case '10'
                                    xc = str2double(values{j});
                                case '20'
                                    yc = str2double(values{j});
                                case '40'
                                    r = str2double(values{j});
                                case '50'
                                    a1 = str2double(values{j});
                                case '51'
                                    a2 = str2double(values{j});
                            end

                            j = j + 1;
                        end

                        if all(isfinite([xc yc r a1 a2]))

                            if a2 < a1
                                a2 = a2 + 360;
                            end

                            th = linspace( ...
                                deg2rad(a1), ...
                                deg2rad(a2), ...
                                121);

                            entities{end+1} = struct( ...
                                'type','ARC', ...
                                'x',xc + r*cos(th), ...
                                'y',yc + r*sin(th)); %#ok<AGROW>
                        end

                        i = j;
                        continue;


                    % ====================================================
                    % ELLIPSE
                    % ====================================================
                    case 'ELLIPSE'

                        j = i + 1;

                        xc = NaN; yc = NaN;
                        majorX = NaN; majorY = NaN;
                        ratio = NaN;
                        t1 = 0;
                        t2 = 2*pi;

                        while j <= numel(codes) && ~strcmp(codes{j},'0')

                            switch codes{j}
                                case '10'
                                    xc = str2double(values{j});
                                case '20'
                                    yc = str2double(values{j});
                                case '11'
                                    majorX = str2double(values{j});
                                case '21'
                                    majorY = str2double(values{j});
                                case '40'
                                    ratio = str2double(values{j});
                                case '41'
                                    t1 = str2double(values{j});
                                case '42'
                                    t2 = str2double(values{j});
                            end

                            j = j + 1;
                        end

                        if all(isfinite([xc yc majorX majorY ratio]))

                            if t2 < t1
                                t2 = t2 + 2*pi;
                            end

                            th = linspace(t1,t2,181);

                            % DXF ellipse:
                            % P = C + major*cos(t) + minor*sin(t)
                            minorX = -majorY * ratio;
                            minorY =  majorX * ratio;

                            x = xc + majorX*cos(th) + minorX*sin(th);
                            y = yc + majorY*cos(th) + minorY*sin(th);

                            entities{end+1} = struct( ...
                                'type','ELLIPSE', ...
                                'x',x, ...
                                'y',y); %#ok<AGROW>
                        end

                        i = j;
                        continue;


                    % ====================================================
                    % SPLINE
                    %
                    % For preview we use its fit points when available;
                    % otherwise its control points. This is intentionally
                    % lightweight and avoids a full NURBS implementation.
                    % ====================================================
                    case 'SPLINE'

                        j = i + 1;

                        fitX = [];
                        fitY = [];
                        controlX = [];
                        controlY = [];

                        pendingFitX = NaN;
                        pendingControlX = NaN;

                        while j <= numel(codes) && ~strcmp(codes{j},'0')

                            switch codes{j}

                                case '11'
                                    pendingFitX = str2double(values{j});

                                case '21'
                                    if isfinite(pendingFitX)
                                        fitX(end+1) = pendingFitX; %#ok<AGROW>
                                        fitY(end+1) = str2double(values{j}); %#ok<AGROW>
                                        pendingFitX = NaN;
                                    end

                                case '10'
                                    pendingControlX = str2double(values{j});

                                case '20'
                                    if isfinite(pendingControlX)
                                        controlX(end+1) = pendingControlX; %#ok<AGROW>
                                        controlY(end+1) = str2double(values{j}); %#ok<AGROW>
                                        pendingControlX = NaN;
                                    end
                            end

                            j = j + 1;
                        end

                        if numel(fitX) >= 2
                            x = fitX;
                            y = fitY;
                        else
                            x = controlX;
                            y = controlY;
                        end

                        if numel(x) >= 2
                            entities{end+1} = struct( ...
                                'type','SPLINE_PREVIEW', ...
                                'x',x, ...
                                'y',y); %#ok<AGROW>
                        end

                        i = j;
                        continue;


                    % ====================================================
                    % POINT
                    % ====================================================
                    case 'POINT'

                        j = i + 1;
                        xp = NaN; yp = NaN;

                        while j <= numel(codes) && ~strcmp(codes{j},'0')
                            switch codes{j}
                                case '10'
                                    xp = str2double(values{j});
                                case '20'
                                    yp = str2double(values{j});
                            end
                            j = j + 1;
                        end

                        if all(isfinite([xp yp]))
                            entities{end+1} = struct( ...
                                'type','POINT', ...
                                'x',xp, ...
                                'y',yp); %#ok<AGROW>
                        end

                        i = j;
                        continue;
                end
            end

            i = i + 1;
        end


        % --------------------------------------------------------
        % Better diagnostic if nothing usable was found
        % --------------------------------------------------------
        if isempty(entities)

            ignored = { ...
                'SECTION','ENDSEC','EOF','TABLE','ENDTAB', ...
                'BLOCK','ENDBLK','SEQEND','VERTEX'};

            detectedTypes = unique(detectedTypes,'stable');
            detectedTypes = detectedTypes( ...
                ~ismember(detectedTypes,ignored));

            if isempty(detectedTypes)
                detectedText = 'No geometric entity types were detected.';
            else
                detectedText = strjoin(detectedTypes,', ');
            end

            error([ ...
                'No supported 2D DXF geometry could be read. ' ...
                'Detected DXF entity types: ' detectedText '. ' ...
                'The reader now supports LINE, LWPOLYLINE, POLYLINE/VERTEX, ' ...
                'CIRCLE, ARC, ELLIPSE, SPLINE preview and POINT. ' ...
                'If the file mainly contains INSERT/BLOCK or HATCH entities, ' ...
                'export/explode the antenna geometry to simple curves in the CAD program.' ...
                ]);
        end
    end


    % ============================================================
    % DXF INSUNITS -> MILLIMETERS
    % ============================================================
    function [scaleToMM,name] = dxfUnitCodeToMM(code)

        switch round(code)

            case 0
                scaleToMM = 1.0;
                name = 'unitless / assumed mm';

            case 1
                scaleToMM = 25.4;
                name = 'inch';

            case 2
                scaleToMM = 304.8;
                name = 'feet';

            case 3
                scaleToMM = 1609344.0;
                name = 'mile';

            case 4
                scaleToMM = 1.0;
                name = 'mm';

            case 5
                scaleToMM = 10.0;
                name = 'cm';

            case 6
                scaleToMM = 1000.0;
                name = 'm';

            case 7
                scaleToMM = 1e6;
                name = 'km';

            case 8
                scaleToMM = 25.4e-6;
                name = 'microinch';

            case 9
                scaleToMM = 0.0254;
                name = 'mil';

            case 10
                scaleToMM = 914.4;
                name = 'yard';

            case 11
                scaleToMM = 1e-7;
                name = 'angstrom';

            case 12
                scaleToMM = 1e-6;
                name = 'nanometer';

            case 13
                scaleToMM = 1e-3;
                name = 'micron';

            case 14
                scaleToMM = 100.0;
                name = 'decimeter';

            otherwise
                scaleToMM = 1.0;
                name = sprintf('INSUNITS=%d / assumed mm',round(code));
        end
    end


    % ============================================================
    % UPDATE LIVE INSPECTOR
    % ============================================================
    function updateInspector(params)

        summaryGeometry.Text = geometryDrop.Value;
        summaryMode.Text = params.mode;
        summaryStructure.Text = structureDrop.Value;

        summarySubstrate.Text = sprintf( ...
            '%.1f × %.1f × %.2f mm', ...
            params.substrateSize, ...
            params.substrateSize, ...
            params.substrateThickness);

        summaryConductor.Text = params.conductorMaterial;
        summaryDielectric.Text = params.dielectricMaterial;
        summaryZmin.Text = params.zminBoundary;
        summaryZmax.Text = params.zmaxBoundary;
        summaryFloquet.Text = num2str(params.floquetNumber);

        designOK = true;
        message = '✓ Design ready for export';

        if params.substrateThickness <= 0
            designOK = false;
            message = '⚠ Substrate thickness must be greater than zero';
        elseif params.substrateSize <= 2*params.a && strcmp(params.type,'gielis')
            designOK = false;
            message = '⚠ Geometry may exceed the substrate';
        elseif strcmp(params.zmaxBoundary,'Et=0')
            message = '⚠ Floquet port on Zmax may be incompatible with Et=0';
        end

        validationLabel.Text = message;

        if designOK
            validationLabel.BackgroundColor = [0.88 0.97 0.90];
        else
            validationLabel.BackgroundColor = [1.00 0.92 0.86];
        end
    end


    % ============================================================
    % INSPECTOR ROW FACTORY
    % ============================================================
    function valueLabel = createInspectorRow(parent,labelText,valueText,ypos)

        uilabel(parent, ...
            'Text',labelText, ...
            'FontWeight','bold', ...
            'FontColor',[0.32 0.36 0.44], ...
            'Position',[15 ypos 105 22]);

        valueLabel = uilabel(parent, ...
            'Text',valueText, ...
            'HorizontalAlignment','right', ...
            'Position',[120 ypos 160 22]);
    end


    % ============================================================
    % PREVIEW HELPERS
    % ============================================================
    function resetPreview()
        axis(ax,'equal');
        axis(ax,'tight');
        drawnow;
        statusLabel.Text = 'View fitted';
    end

    function toggleGrid()
        if showGridCheck.Value
            grid(ax,'on');
        else
            grid(ax,'off');
        end
    end


    % ============================================================
    % SAVE DESIGN
    % ============================================================
    function saveCurrentDesign()

        params = collectParams();

        [fileName,pathName] = uiputfile( ...
            'metamaterial_design.mat', ...
            'Save Metamaterial Design');

        if isequal(fileName,0)
            return;
        end

        save(fullfile(pathName,fileName),'params');

        statusLabel.Text = 'Design saved';
        lastActionLabel.Text = ['Saved: ' fileName];
    end


    % ============================================================
    % SLIDER FACTORY
    % ============================================================
    function slider = createSlider( ...
        parent, ...
        label, ...
        value, ...
        limits, ...
        ypos, ...
        isInteger)

        if nargin < 6

            isInteger = false;
        end


        % ========================================================
        % LABEL
        % ========================================================
        uilabel(parent, ...
            'Text',label, ...
            'Position',[10 ypos+5 105 22]);


        % ========================================================
        % SLIDER
        % ========================================================
        slider = uislider(parent, ...
            'Position',[120 ypos+15 240 3], ...
            'Limits',limits, ...
            'Value',value);


        % ========================================================
        % INTEGER SLIDER
        % ========================================================
        if isInteger

            slider.Value = ...
                round(value);

            valueLabel = uilabel(parent, ...
                'Text', ...
                num2str(round(value),'%d'), ...
                'Position',[370 ypos+5 50 22]);

            slider.ValueChangedFcn = ...
                @(src,event) ...
                updateIntegerSlider( ...
                    src, ...
                    valueLabel);


        % ========================================================
        % FLOAT SLIDER
        % ========================================================
        else

            valueLabel = uilabel(parent, ...
                'Text', ...
                num2str(value,'%.2f'), ...
                'Position',[370 ypos+5 50 22]);

            slider.ValueChangedFcn = ...
                @(src,event) ...
                updateFloatSlider( ...
                    src, ...
                    valueLabel);
        end
    end


    % ============================================================
    % INTEGER SLIDER CALLBACK
    % ============================================================
    function updateIntegerSlider(src,label)

        src.Value = ...
            round(src.Value);

        set( ...
            label, ...
            'Text', ...
            num2str(src.Value,'%d'));


        % ========================================================
        % SPECIAL CASE:
        % NUMBER OF RINGS CHANGED
        %
        % Synchronize SSRR split-position table.
        % ========================================================
        if src == ringsSlider

            updateSplitTable();
        end


        updatePlot();
    end


    % ============================================================
    % FLOAT SLIDER CALLBACK
    % ============================================================
    function updateFloatSlider(src,label)

        set( ...
            label, ...
            'Text', ...
            num2str(src.Value,'%.2f'));

        updatePlot();
    end

function spinner = createSpinner(parent,label,value,limits,step,ypos,isInteger)

        if nargin<7
            isInteger=false;
        end
        
        uilabel(parent,...
            'Text',label,...
            'Position',[10 ypos 130 22]);
        
        spinner = uispinner(parent,...
            'Position',[170 ypos 90 22],...
            'Limits',limits,...
            'Value',value,...
            'Step',step);
        
        if isInteger
            spinner.RoundFractionalValues='on';
        end
        
        spinner.ValueChangedFcn=@(~,~)updatePlot();
        
        end

end