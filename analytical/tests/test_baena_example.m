function test_baena_example()
%TEST_BAENA_EXAMPLE  Plausibility check against a textbook circular EC-SRR.
%
%   Circular SRR, edge-coupled, from the range used throughout Marques/Baena:
%     external radius  r_ext = 3.0 mm
%     strip width      c     = 0.3 mm
%     ring separation  d     = 0.3 mm
%     substrate        er = 10.2, h = 1.27 mm (Rogers RO3010)
%     split gap        g     = 0.3 mm
%   Published measured/simulated f0 for inclusions of this class sits around
%   2-4 GHz. An exact match needs the paper's own L/C numbers, so this test
%   only bounds the order of magnitude - it guards against unit slips and
%   sign errors in the pipeline, not model accuracy.

    here = fileparts(mfilename('fullpath'));
    addpath(fileparts(here));
    addpath(fullfile(fileparts(fileparts(here)), 'geometry'));

    r_ext = 3.0; c = 0.3; d = 0.3;
    r_int = r_ext - (2*c + d);           % inner radius of the inner ring

    % two concentric closed rings as BUILDMETAMATERIAL would produce them
    th = linspace(0, 2*pi, 720);
    ring = struct( ...
        'outerX', r_ext*cos(th), 'outerY', r_ext*sin(th), ...
        'innerX', r_int*cos(th), 'innerY', r_int*sin(th));

    params = struct('type','gielis','mode','SRR', ...
        'thickness', c, 'spacing', d, 'splitGap', 0.3, ...
        'substrateThickness', 1.27, 'substrate_er', 10.2, ...
        'substrateSize', 10);

    s1 = srrLcModel({ring, ring}, params);

    fprintf('  circular EC-SRR : f0 = %.2f GHz , L = %.2f nH , C = %.3f pF\n', ...
        s1.f0/1e9, s1.L*1e9, s1.C*1e12);

    assert(s1.f0 > 1.0e9 && s1.f0 < 8.0e9, ...
        'f0 = %.2f GHz outside the plausible 1-8 GHz band', s1.f0/1e9);
    assert(s1.L*1e9 > 1 && s1.L*1e9 < 50, 'L outside 1-50 nH');
    assert(s1.C*1e12 > 0.05 && s1.C*1e12 < 20, 'C outside 0.05-20 pF');

    disp('  test_baena_example PASSED');
end
