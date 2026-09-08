function test_nrw_roundtrip()
%TEST_NRW_ROUNDTRIP  Synthesize slab S-parameters from a known passive medium,
%   retrieve, and confirm the effective parameters come back.

    addpath(fileparts(fileparts(mfilename('fullpath'))));

    f = linspace(2e9, 12e9, 500).';
    d = 1.6e-3;

    w  = 2*pi*f;
    w0 = 2*pi*7e9;
    F  = 0.30;
    G  = w0 / 40;

    muT  = 1 - F.*w.^2 ./ (w.^2 - w0^2 + 1i.*w.*G);   % Lorentzian, passive
    epsT = 4.3 * (1 + 1i*0.02) * ones(size(f));

    [S11, S21] = slabSParameters(f, epsT, muT, d);
    r = nrwRetrieval(f, S11, S21, d);

    errEps = max(abs(r.eps - epsT));
    errMu  = max(abs(r.mu  - muT));

    fprintf('  max |d eps| = %.2e , max |d mu| = %.2e\n', errEps, errMu);
    assert(errEps < 1e-6, 'epsilon round-trip error too large');
    assert(errMu  < 1e-6, 'mu round-trip error too large');

    % passivity of the synthesized data
    assert(all(abs(S11) <= 1 + 1e-9) && all(abs(S21) <= 1 + 1e-9), ...
        'synthesized S-parameters are not passive');

    disp('  test_nrw_roundtrip PASSED');
end
