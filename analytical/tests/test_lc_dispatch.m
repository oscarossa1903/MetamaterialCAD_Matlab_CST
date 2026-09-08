function test_lc_dispatch()
%TEST_LC_DISPATCH  Stage 1 returns finite, positive L, C, f0 for both a Gielis
%   ring and a square SRR built by BUILDMETAMATERIAL, in SRR and CSRR mode.

    here = fileparts(mfilename('fullpath'));
    addpath(fileparts(here));
    addpath(fullfile(fileparts(fileparts(here)), 'geometry'));

    % --- Gielis (near-circular) ---------------------------------------
    pg = struct('type','gielis','mode','SRR', ...
        'm',6,'n1',1,'n2',1,'n3',1,'a',5, ...
        'numRings',2,'thickness',0.2,'spacing',0.3,'res',600, ...
        'splitGap',0.3,'substrateThickness',1.6,'dielectricMaterial','FR4', ...
        'substrateSize',12);
    gg = buildMetamaterial(pg);
    checkModel(srrLcModel(gg, pg), 'gielis SRR', 'circular');
    pg.mode = 'CSRR';
    checkModel(srrLcModel(gg, pg), 'gielis CSRR', 'circular');

    % --- Square SRR --------------------------------------------------
    ps = struct('type','ssrr','mode','SRR', ...
        'W',10,'L',8,'numRings',2,'spacing',0.3,'thickness',0.2, ...
        'gapSSRR',0.5,'gapPositions',{{'right','left'}}, ...
        'splitGap',0.5,'substrateThickness',1.6,'dielectricMaterial','FR4', ...
        'substrateSize',12);
    gs = buildMetamaterial(ps);
    checkModel(srrLcModel(gs, ps), 'square SRR', 'square');
    ps.mode = 'CSRR';
    checkModel(srrLcModel(gs, ps), 'square CSRR', 'square');

    disp('  test_lc_dispatch PASSED');
end

% ----------------------------------------------------------------------
function checkModel(s1, name, wantShape)
    fprintf('  %-14s : f0 = %6.2f GHz , L = %5.2f nH , C = %6.3f pF (%s)\n', ...
        name, s1.f0/1e9, s1.L*1e9, s1.C*1e12, s1.shape);
    assert(isfinite(s1.f0) && s1.f0 > 0, '%s: bad f0', name);
    assert(isfinite(s1.L) && s1.L > 0,  '%s: bad L',  name);
    assert(isfinite(s1.C) && s1.C > 0,  '%s: bad C',  name);
    assert(s1.f0 > 0.2e9 && s1.f0 < 60e9, '%s: f0 out of plausible range', name);
    assert(strcmp(s1.shape, wantShape), '%s: shape dispatch wrong', name);
end
