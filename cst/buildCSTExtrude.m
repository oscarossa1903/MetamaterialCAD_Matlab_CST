function cmd = buildCSTExtrude(name,component,material,X,Y,z0,height)
%BUILDCSTEXTRUDE Solid with real thickness from a closed XY polygon.
%
%   cmd = buildCSTExtrude(name,component,material,X,Y,z0,height)
%
%   The polygon (X,Y) lies on the plane z = z0 and is extruded
%   'height' mm in +Z (from z0 to z0+height). Uses CST "Extrude"
%   in Pointlist mode, so no auxiliary curve is created.
%
%   Consecutive duplicate points and the repeated closing point are
%   removed because CST closes the point list automatically.

    X = X(:).';
    Y = Y(:).';

    % Remove consecutive duplicates
    if numel(X) > 1
        d = hypot(diff(X),diff(Y));
        keep = [true, d > 1e-9];
        X = X(keep);
        Y = Y(keep);
    end

    % Remove closing point (CST closes the polygon itself)
    if numel(X) > 1 && hypot(X(end)-X(1),Y(end)-Y(1)) <= 1e-9
        X(end) = [];
        Y(end) = [];
    end

    if numel(X) < 3
        error('buildCSTExtrude: polygon "%s" has fewer than 3 points.',name);
    end

    cmd = [ ...
        'With Extrude' newline ...
        '    .Reset' newline ...
        sprintf('    .Name "%s"\n',name) ...
        sprintf('    .Component "%s"\n',component) ...
        sprintf('    .Material "%s"\n',material) ...
        '    .Mode "Pointlist"' newline ...
        sprintf('    .Height "%.6f"\n',height) ...
        '    .Twist "0.0"' newline ...
        '    .Taper "0.0"' newline ...
        sprintf('    .Origin "0.0", "0.0", "%.6f"\n',z0) ...
        '    .Uvector "1.0", "0.0", "0.0"' newline ...
        '    .Vvector "0.0", "1.0", "0.0"' newline ...
        sprintf('    .Point "%.6f", "%.6f"\n',X(1),Y(1))];

    for n = 2:numel(X)
        cmd = [cmd sprintf('    .LineTo "%.6f", "%.6f"\n',X(n),Y(n))]; %#ok<AGROW>
    end

    cmd = [cmd ...
        '    .Create' newline ...
        'End With' newline newline];
end
