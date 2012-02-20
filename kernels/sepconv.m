function y_t = sepconv(X_fht, kernel)
% function y_t = sepconv(X_fht, kernel)
% 
% Calculate output of separable kernel to stimulus X_fht
%
% Inputs:
%  X_fht -- tensorized stimulus
%  kernel -- separable kernel containing k_f, k_h, c_f, c_h
% 
% Output:
%  y_t -- response vector

X_fht(end+1, end+1, :) = 1;

k_f = [kernel.k_f; kernel.c_f];
k_h = [kernel.k_h; kernel.c_h];

[n_f, n_h, n_t] = size(X_fht);

a_fht = X_fht.*repmat(k_f, [1 n_h n_t]);
a_ht = squeeze(sum(a_fht, 1));
y_t = sum(a_ht .* repmat(k_h, [1 n_t]), 1);


