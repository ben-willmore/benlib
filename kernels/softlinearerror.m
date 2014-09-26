function  [E, dE] = softlinearerror(X, fitdata)
% error and partial derivatives for soft threshold linear model
% of neuronal output nonlinearity
% [E, dE] = sigmoidSSE_partials(X, fitdata)
% X is a vector of arguments:
%   a = X(1); % minimum
%   b = X(2); % range
%   c = X(3); % offset to right
%   d = X(4); % gradient
% fitdata is a struct:
%   fitdata.y_t is observed values (vector, <t x 1>) column
%   fitdata.z_t is predicted values (vector, <t x 1>) column
%
% E is the function value (sum-of-squared-errors)
% dE is a vector of partial derivatives (by a,b,c,d of X)
%

% This has been checked with checkgrad.m:
% fitdata.y_t = rand(200,1); fitdata.z_t = rand(200,1);
% d = checkgrad('softlinearerror', rand(4,1), 1e-5, fitdata)

a = X(1); % y-offset
b = X(2); % slope
c = X(3); % x-offset
d = X(4); % sharpness of transition

y_t = fitdata.y_t;
z_t = fitdata.z_t;

% f(P,z_t)
% PREVIOUS VERSION BW:
%log_tmp = log(1+exp(z_t-c));
%fX = a + b.*log_tmp;
exp_tmp = exp(d*(z_t-c));
log_tmp = log(1+exp_tmp);
fX = a + b./d.*log_tmp;

% E
residuals = fX - y_t;
E = sum(residuals.^2);

% PARTIALS
% PREVIOUS VERSION BW:
% dE = nan(3,1);
% dE(1) = sum(2*residuals);
% dE(2) = sum(2.*log_tmp.*residuals);
% dE(3) = -sum((2*b*exp(z_t).*residuals)./(exp(c)+exp(z_t)));
%
% Partial derivatives from Wolfram Alpha

dE = nan(4,1);
dE(1) = sum(2*residuals);
dE(2) = sum(2./(d^2).*log_tmp.*(d*(a-y_t)+b.*log_tmp));
dE(3) = -sum(2*b*exp_tmp.*residuals./(exp_tmp+1));
tmp1 = d*(c-z_t).*exp(d*z_t);
tmp2 = exp(c*d)+exp(d*z_t);

dE(4) = -sum(2*b/(d^2)*(tmp1./tmp2 + log_tmp).*residuals);

