function [x,y] = generateSpiral(a,b,turns,res)

    theta = linspace(0,turns*2*pi,res);

    r = a + b*theta;

    x = r .* cos(theta);
    y = r .* sin(theta);
end