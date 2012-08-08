function kernel = blasso_fht(X_fht, y_t)

params = struct;
params.display_kernel = false;
params.suppress_display = true;

[n_f, n_h, n_t] = size(X_fht);

X_fit_fh_t = reshape(X_fht, [n_f*n_h], size(X_fht, 3));
[k_fh_1d, kernel.c] = blasso_bw4(X_fit_fh_t', y_t', params);

kernel.k_fh = reshape(k_fh_1d, n_f, n_h);
