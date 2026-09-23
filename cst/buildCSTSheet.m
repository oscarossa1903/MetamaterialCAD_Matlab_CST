function cmd = buildCSTSheet(curveName,sheetName,material,component,curveFolder)
%BUILDCSTSHEET Cover a closed curve to create a sheet solid.
%   component   (optional) default 'component1'
%   curveFolder (optional) default 'Curve1'

if nargin < 4 || isempty(component)
    component = 'component1';
end

if nargin < 5 || isempty(curveFolder)
    curveFolder = 'Curve1';
end

cmd = '';

cmd = [cmd ...
    'With CoverCurve' newline ...
    '    .Reset' newline];

cmd = [cmd ...
    sprintf('    .Name "%s"\n',sheetName)];

cmd = [cmd ...
    sprintf('    .Component "%s"\n',component)];

cmd = [cmd ...
    sprintf('    .Material "%s"\n',material)];

cmd = [cmd ...
    sprintf('    .Curve "%s:%s"\n',curveFolder,curveName)];

cmd = [cmd ...
    '    .Create' newline ...
    'End With' newline newline];
