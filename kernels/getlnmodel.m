function model = getlnmodel(z_fit, y_fit)
% function model = getlnmodel(z_fit, y_fit)

fitdata.y_t = y_fit;
fitdata.z_t = z_fit;

% initialise fit params
fitparams.restarts = 8;
fitparams.options = optimset('Algorithm','sqp', 'Display', 'off');
fitparams.model = @lnmodel;

% data driven starting values (could also be used as priors)
zrange = iqr(z_fit);
zmean = mean(z_fit);
yrange = iqr(y_fit);
ymin = prctile(y_fit, 25);

%a ~ Exp(ymin + 0.05) 
%b ~ Exp(yrange * 2) % not using *2
%c ~ N(zmean, zrange ^ 2)
%d ~ Exp(0.1 * zrange)
fitparams.x0fun = {@() exprnd(ymin+0.05) @() exprnd(yrange) ...
       			     @() (randn*zrange)+zmean @() exprnd(0.1*zrange)};
fitparams.params = {[], [], [], [], [0 0 -Inf 0], [], []};

model = fitmodel3(fitparams, fitdata);
