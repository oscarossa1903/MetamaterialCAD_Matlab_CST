function arrayGeom = buildArray( ...
    unitGeom, ...
    Nx, Ny, ...
    dx, dy, ...
    offsetX, offsetY, ...
    centered)

arrayGeom = {};

idx = 1;

% ============================================================
% CENTERING
% ============================================================
if centered

    xc = (Nx-1)*dx/2;
    yc = (Ny-1)*dy/2;

else

    xc = 0;
    yc = 0;
end

% ============================================================
% ARRAY
% ============================================================
for ix = 0:(Nx-1)

    for iy = 0:(Ny-1)

        tx = ix*dx - xc + offsetX;
        ty = iy*dy - yc + offsetY;

        for k = 1:length(unitGeom)

            g = unitGeom{k};

            arrayGeom{idx} = struct( ...
                'outerX', g.outerX + tx, ...
                'outerY', g.outerY + ty, ...
                'innerX', g.innerX + tx, ...
                'innerY', g.innerY + ty);

            idx = idx + 1;
        end
    end
end