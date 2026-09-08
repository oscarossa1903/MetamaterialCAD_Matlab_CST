function test_passivity()
%TEST_PASSIVITY  Retrieved parameters from a passive slab obey passivity:
%   Im(eps) >= 0, Im(mu) >= 0, Re(z) >= 0   (exp(-i w t) convention).

    addpath(fileparts(fileparts(mfilename('fullpath'))));

    f = linspace(1e9, 15e9, 900).';
    d = 2.0e-3;

    w  = 2*pi*f;
    w0 = 2*pi*8e9;
    F  = 0.4;
    G  = w0 / 25;

    epsT = 3.0 * (1 + 1i*0.01) * ones(size(f));
    muT  = 1 - F.*w.^2 ./ (w.^2 - w0^2 + 1i.*w.*G);

    [S11, S21] = slabSParameters(f, epsT, muT, d);
    r = nrwRetrieval(f, S11, S21, d);

    tol = 1e-6;
    assert(all(imag(r.eps) > -tol), 'Im(eps) < 0 detected');
    assert(all(imag(r.mu)  > -tol), 'Im(mu) < 0 detected');
    assert(all(real(r.z)   > -tol), 'Re(z) < 0 detected');

    disp('  test_passivity PASSED');
end
