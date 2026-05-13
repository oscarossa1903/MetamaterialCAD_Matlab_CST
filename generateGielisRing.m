function [xo,yo,xi,yi] = generateGielisRing( ...
    m,n1,n2,n3, ...
    outerRadius, ...
    thickness, ...
    gapAngle, ...
    N)

    % ============================================================
    % ANGULAR DOMAIN
    % ============================================================
    theta = linspace(0,2*pi,N);

    % ============================================================
    % GAP
    % ============================================================
    gapCenter = 0;

    gapStart = gapCenter - gapAngle/2;
    gapEnd   = gapCenter + gapAngle/2;

    mask = ~(theta > gapStart & theta < gapEnd);

    theta = theta(mask);

    % ============================================================
    % OUTER SHAPE
    % ============================================================
    rOuter = gielisRadius( ...
        theta,m,n1,n2,n3);

    rOuter = rOuter ./ max(rOuter);

    rOuter = rOuter * outerRadius;

    xo = rOuter .* cos(theta);
    yo = rOuter .* sin(theta);

    % ============================================================
    % INNER SHAPE
    % ============================================================
    innerRadius = outerRadius - thickness;

    rInner = gielisRadius( ...
        theta,m,n1,n2,n3);

    rInner = rInner ./ max(rInner);

    rInner = rInner * innerRadius;

    xi = rInner .* cos(theta);
    yi = rInner .* sin(theta);

    % ============================================================
    % CLOSE OUTER CURVE
    % ============================================================
    xo(end+1) = xo(1);
    yo(end+1) = yo(1);

    % ============================================================
    % CLOSE INNER CURVE
    % ============================================================
    xi(end+1) = xi(1);
    yi(end+1) = yi(1);
end