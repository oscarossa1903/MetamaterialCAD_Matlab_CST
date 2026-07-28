function [xo,yo,xi,yi] = generateGielisRing( ...
    m,n1,n2,n3,...
    outerRadius,...
    thickness,...
    N)
%GENERATEGIELISRING Generate a closed Gielis ring.
%
% INPUTS
%   m            - Symmetry parameter
%   n1,n2,n3     - Gielis shape parameters
%   outerRadius  - Outer radius (mm)
%   thickness    - Metal width (mm)
%   N            - Number of samples
%
% OUTPUTS
%   xo,yo        - Closed outer contour
%   xi,yi        - Closed inner contour

    %--------------------------------------------------------------
    % Check geometry
    %--------------------------------------------------------------
    if thickness >= outerRadius
        error('Thickness must be smaller than the outer radius.');
    end

    %--------------------------------------------------------------
    % Angular samples
    %--------------------------------------------------------------
    theta = linspace(0,2*pi,N);

    %--------------------------------------------------------------
    % Normalized Gielis radius
    %--------------------------------------------------------------
    r = gielisRadius(theta,m,n1,n2,n3);

    r = r ./ max(r);

    %--------------------------------------------------------------
    % Outer contour
    %--------------------------------------------------------------
    rOuter = outerRadius * r;

    xo = rOuter .* cos(theta);
    yo = rOuter .* sin(theta);

    %--------------------------------------------------------------
    % Inner contour
    %--------------------------------------------------------------
    innerRadius = outerRadius - thickness;

    rInner = innerRadius * r;

    xi = rInner .* cos(theta);
    yi = rInner .* sin(theta);

    %--------------------------------------------------------------
    % Close polygons
    %--------------------------------------------------------------
    xo(end+1) = xo(1);
    yo(end+1) = yo(1);

    xi(end+1) = xi(1);
    yi(end+1) = yi(1);

end