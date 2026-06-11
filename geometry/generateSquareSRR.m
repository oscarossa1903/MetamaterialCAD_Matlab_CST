function [outerX, outerY, innerX, innerY] = generateSquareSRR(side, thickness, gap, position)
    if nargin < 4, position = 'right'; end
    
    sO = side / 2;
    sI = sO - thickness;
    
    % Define the "right" gap base case:
    % Path: [-s, -s] -> [s, -s] -> [s, gap] -> [s-gap, s] -> [-s, s] -> [-s, -s]
    ox = [-sO,  sO,  sO,  sO-gap, -sO, -sO];
    oy = [-sO, -sO, gap, sO,      sO, -sO];
    
    ix = [-sI,  sI,  sI,  sI-gap, -sI, -sI];
    iy = [-sI, -sI, gap, sI,      sI, -sI];
    
    % Use coordinate swapping to rotate without floating-point errors
    switch lower(position)
        case 'right'
            % No change
        case 'top'
            [ox, oy] = swapCoords(ox, oy, 'top');
            [ix, iy] = swapCoords(ix, iy, 'top');
        case 'left'
            [ox, oy] = swapCoords(ox, oy, 'left');
            [ix, iy] = swapCoords(ix, iy, 'left');
        case 'bottom'
            [ox, oy] = swapCoords(ox, oy, 'bottom');
            [ix, iy] = swapCoords(ix, iy, 'bottom');
        otherwise
            error('Invalid position. Use: right, top, left, bottom.');
    end
    
    outerX = ox; outerY = oy;
    innerX = ix; innerY = iy;
end

function [nx, ny] = swapCoords(x, y, pos)
    % Rotate vertices exactly 90 degrees using coordinate mapping
    % This avoids rounding errors found in sin/cos rotations
    switch pos
        case 'top'    % (x, y) -> (-y, x)
            nx = -y; ny = x;
        case 'left'   % (x, y) -> (-x, -y)
            nx = -x; ny = -y;
        case 'bottom' % (x, y) -> (y, -x)
            nx = y;  ny = -x;
    end
end