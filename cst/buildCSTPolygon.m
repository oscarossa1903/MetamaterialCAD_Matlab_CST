function cmd = buildCSTPolygon(x,y,z,name,mode)

    cmd = '';

    % ============================================================
    % OPEN POLYGON FOR SRR GAP
    % ============================================================
    cmd = [cmd ...
        'With Polygon3D' newline ...
        '    .Reset' newline];

    cmd = [cmd ...
        sprintf('    .Name "%s"\n',name)];

    cmd = [cmd ...
        '    .Curve "Curve1"' newline];

    % ============================================================
    % POINTS
    % ============================================================
    for n = 1:length(x)

        cmd = [cmd ...
            sprintf( ...
            '    .Point "%f", "%f", "%f"\n', ...
            x(n), ...
            y(n), ...
            z)];
    end

    % ============================================================
    % CREATE OPEN CURVE
    % ============================================================
    cmd = [cmd ...
        '    .Create' newline ...
        'End With' newline newline];
end