function m = polygonMetrics(x, y)
%POLYGONMETRICS  Perimeter, area and equivalent radii of a closed polygon.
%
%   m = polygonMetrics(x, y) returns a struct with fields
%     perimeter  - sum of edge lengths (open curves are closed implicitly)
%     area       - enclosed area (shoelace, absolute value)
%     rEquivA    - radius of a disc of the same area:      sqrt(area/pi)
%     rEquivP    - radius of a circle of the same perimeter: perimeter/(2*pi)
%     rMean      - mean distance of the vertices from their centroid
%
%   Units follow the inputs (this project works in mm inside the GUI and in
%   metres inside the analytical pipeline - the caller converts).

    x = x(:); y = y(:);

    if x(end) ~= x(1) || y(end) ~= y(1)
        x(end+1) = x(1);
        y(end+1) = y(1);
    end

    dx = diff(x); dy = diff(y);
    m.perimeter = sum(hypot(dx, dy));

    m.area = abs(sum(x(1:end-1).*y(2:end) - x(2:end).*y(1:end-1))) / 2;

    m.rEquivA = sqrt(m.area / pi);
    m.rEquivP = m.perimeter / (2*pi);

    cx = mean(x(1:end-1)); cy = mean(y(1:end-1));
    m.rMean = mean(hypot(x(1:end-1) - cx, y(1:end-1) - cy));
end
