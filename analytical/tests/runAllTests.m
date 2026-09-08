function runAllTests()
%RUNALLTESTS  Run every analytical-pipeline test script.

    here = fileparts(mfilename('fullpath'));
    addpath(here);
    addpath(fileparts(here));

    tests = { ...
        @test_nrw_roundtrip, ...
        @test_passivity, ...
        @test_touchstone, ...
        @test_lc_dispatch, ...
        @test_baena_example};

    nPass = 0;
    for k = 1:numel(tests)
        name = func2str(tests{k});
        fprintf('%s\n', name);
        try
            tests{k}();
            nPass = nPass + 1;
        catch ME
            fprintf(2, '  FAILED: %s\n', ME.message);
        end
    end

    fprintf('\n%d / %d test scripts passed.\n', nPass, numel(tests));
end
