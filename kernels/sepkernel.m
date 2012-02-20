function kernel = separablekernel(X_ft, y_t, n_h)
% function kernel = separablekernel(X_ft, y_t, n_h)
% 
% Compute separable kernel
%
% Inputs:
%  X_ft -- stimulus, freq x time
%  y_t -- response, 1-D time series
%  n_h -- number of history steps desired
% 
% Output:
%  kernel.k_f -- frequency kernel
%  kernel.k_h -- history kernel
%  kernel.c_f -- constant term for freq
%  kernel.c_h -- constant term for history


X_fht = tensorize(X_ft, n_h);
X_fht(end+1, end+1, :) = 1;

[n_f, n_h, n_t] = size(X_fht);

k_f = ones(n_f, 1);
k_h = ones(n_h, 1);

for ii = 1:15
 yh = X_fht.*repmat(k_f, [1 n_h n_t]);
 yh = squeeze(sum(yh, 1));
 k_h = lsqlin(yh', y_t);

 yh = X_fht.*repmat(k_h', [n_f 1 n_t]);
 yh = squeeze(sum(yh, 2));
 k_f = lsqlin(yh', y_t);
end

% separate out constant terms
kernel.c_f = k_f(end);
kernel.k_f = k_f(1:end-1);
kernel.c_h = k_h(end);
kernel.k_h = k_h(1:end-1);
