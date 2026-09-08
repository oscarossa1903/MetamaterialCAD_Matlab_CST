function [xo,yo,xi,yi] = generateGielisRing( ...
    m,n1,n2,n3,...
    outerRadius,...
    thickness,...
    N,...
    gap,...
    gapPosition)
%GENERATEGIELISRING Generate a Gielis ring, optionally split by a gap.
%
% INPUTS
%   m            - Symmetry parameter
%   n1,n2,n3     - Gielis shape parameters
%   outerRadius  - Outer radius (mm)
%   thickness    - Metal width (mm)
%   N            - Number of samples
%   gap          - Split-gap width (mm). 0 or omitted -> closed ring.
%   gapPosition  - Angle of the split centre (rad). Default pi/2.
%
% OUTPUTS
%   gap <= 0 :  xo,yo closed outer contour  and  xi,yi closed inner contour.
%   gap  > 0 :  xo,yo is a single closed C-shaped ribbon polygon tracing the
%               split annulus; xi,yi are returned empty. This matches the
%               single-closed-polygon convention used by GENERATESQUARESRR,
%               so the preview and the CST exporter handle it with no extra
%               branching.

    if nargin < 8 || isempty(gap);         gap = 0;            end
    if nargin < 9 || isempty(gapPosition); gapPosition = pi/2; end

    %--------------------------------------------------------------
    % Check geometry
    %--------------------------------------------------------------
    if thickness >= outerRadius
        error('Thickness must be smaller than the outer radius.');
    end

    innerRadius = outerRadius - thickness;

    %--------------------------------------------------------------
    % Angular samples + normalized Gielis radius
    %--------------------------------------------------------------
    theta = linspace(0,2*pi,N);

    r = gielisRadius(theta,m,n1,n2,n3);
    r = r ./ max(r);

    rOuter = outerRadius * r;
    rInner = innerRadius * r;

    xoAll = rOuter .* cos(theta);
    yoAll = rOuter .* sin(theta);

    xiAll = rInner .* cos(theta);
    yiAll = rInner .* sin(theta);

    %--------------------------------------------------------------
    % CLOSED RING (no split)
    %--------------------------------------------------------------
    if gap <= 0

        xo = [xoAll, xoAll(1)];
        yo = [yoAll, yoAll(1)];

        xi = [xiAll, xiAll(1)];
        yi = [yiAll, yiAll(1)];

        return;
    end

    %--------------------------------------------------------------
    % SPLIT RING -> single closed C-shaped ribbon
    %--------------------------------------------------------------
    dPhiO = (gap/2) / mean(rOuter);
    dPhiI = (gap/2) / mean(rInner);

    phi = mod(theta - gapPosition, 2*pi);   % 0 at the gap centre

    maskO = phi > dPhiO & phi < (2*pi - dPhiO);
    maskI = phi > dPhiI & phi < (2*pi - dPhiI);

    [~,so] = sort(phi(maskO));
    [~,si] = sort(phi(maskI));

    xoArc = xoAll(maskO); xoArc = xoArc(so);
    yoArc = yoAll(maskO); yoArc = yoArc(so);

    xiArc = xiAll(maskI); xiArc = xiArc(si);
    yiArc = yiAll(maskI); yiArc = yiArc(si);

    % outer edge (gap+ -> around -> gap-), then inner edge back, then close
    xo = [xoArc, fliplr(xiArc), xoArc(1)];
    yo = [yoArc, fliplr(yiArc), yoArc(1)];

    xi = [];
    yi = [];
end
