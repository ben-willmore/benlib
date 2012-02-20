function yhat_t = lnmodel(x, data)
% function yhat_t = lnmodel(x, data)
% 
% Calculate sigmoid LN model
% 
% Inputs:
%  x -- parameters
%  data.z_t -- output of separable kernel

a = x(1);
b = x(2);
c = x(3);
d = x(4);

z_t = data.z_t;

g = 1./(1+exp(-(z_t-c)/d));

yhat_t = a + b*g;
