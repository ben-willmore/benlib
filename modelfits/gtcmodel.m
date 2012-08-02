function yhat_t = gaintimecoursemodel(x, data)
% gain model with time course

a = x(1);
b = x(2);
c_L = x(3);
c_H = x(4);
d_L = x(5);
d_H = x(6);
tau = x(7);

z_t = data.z_t;
C_ht = data.C_ht;

% this should be done using milliseconds, not chord_fs steps
h = (size(C_ht,1)-1:-1:0)';
lambda_h = repmat(exp(-h/tau),[1 size(C_ht,2)]);
kappa_h = lambda_h./ ...
          repmat(sum(lambda_h,1), [size(lambda_h, 1), 1]);

c_t = c_L + (c_H-c_L)*sum(kappa_h.*C_ht, 1);
d_t = d_L + (d_H-d_L)*sum(kappa_h.*C_ht, 1);

g = 1./(1+exp(-(z_t-c_t)./d_t));

yhat_t = a + b*g;

if isfield(data, 'pause');
  plot(data.C_t);
  hold all;
  ctnorm = c_t-min(c_t);
  ctnorm = ctnorm/max(ctnorm);
  plot(ctnorm+1.2);
  dtnorm = d_t-min(d_t);
  dtnorm = dtnorm/max(dtnorm);
  plot(dtnorm+2.4);
  hold off;
  legend({'\sigma';'c';'d'})
  keyboard;
end
%keyboard