function kernel = separable_kernel(X_fht, y_dt, fit_idx, pred_idx)

y_t = mean(y_dt, 1);
kernel = sepkerneltensor2(X_fht(:,:,fit_idx), y_t(fit_idx));
kernel.k_fh = kernel.k_f * transpose(kernel.k_h);
kernel.convfunc = @sepconv;
kernel.y_hat = sepconv(X_fht, kernel);

% evaluate it on fit data
[kernel.cc_norm_fit, kernel.cc_abs_fit, kernel.cc_max_fit] = ...
    calc_CCnorm(y_dt(:,fit_idx), kernel.y_hat(fit_idx));

% evaluate it on prediction data
[kernel.cc_norm_pred, kernel.cc_abs_pred, kernel.cc_max_pred] = ...
    calc_CCnorm(y_dt(:,pred_idx), kernel.y_hat(pred_idx));
