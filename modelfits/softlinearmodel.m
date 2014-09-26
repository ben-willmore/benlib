function yhat_t = softlinearmodel(x, data)
% function yhat_t = lnmodel(x, data)
% 
% Calculate soft threshold linear LN model
% 
% Inputs:
%  x -- parameters
%  data.z_t -- output of separable kernel

a = x(1); % y-offset
b = x(2); % slope
c = x(3); % x-offset
d = x(4); % sharpness of transition

if isstruct(data)
  z_t = data.z_t;
else
  z_t = data;
end

%yhat_t = a + b.*log(1+exp(z_t-c));
yhat_t = a + b./d.*log(1+exp(d*(z_t-c)));
