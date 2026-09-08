function [er, tand] = substratePermittivity(name)
%SUBSTRATEPERMITTIVITY  Relative permittivity / loss tangent for a named board.
%
%   [er, tand] = substratePermittivity(name) maps the dielectric-material
%   strings used by the GUI dropdowns to numeric values. Unknown names fall
%   back to FR-4.

    if nargin < 1 || isempty(name); name = 'FR4'; end
    key = lower(regexprep(char(name), '\s+', ''));

    switch true
        case contains(key, 'rogers4350') || contains(key, 'ro4350')
            er = 3.48;  tand = 0.0037;
        case contains(key, 'rogers5880') || contains(key, 'rt5880') || contains(key, 'duroid')
            er = 2.20;  tand = 0.0009;
        case contains(key, 'rogers3003') || contains(key, 'ro3003')
            er = 3.00;  tand = 0.0010;
        case contains(key, 'alumina')
            er = 9.80;  tand = 0.0001;
        case contains(key, 'teflon') || contains(key, 'ptfe')
            er = 2.10;  tand = 0.0002;
        case contains(key, 'air') || contains(key, 'vacuum')
            er = 1.00;  tand = 0.0;
        otherwise   % FR-4
            er = 4.30;  tand = 0.025;
    end
end
