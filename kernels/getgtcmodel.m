function model = getgtcmodel(z_fit, C_ht_fit, y_fit, gainmodel)
% function model = getgtcmodel(z_fit, C_ht_fit, y_fit)

fitdata.y_t = y_fit;
fitdata.z_t = z_fit;
fitdata.C_ht = C_ht_fit;

% initialise fit params
fitparams.restarts = 20;
fitparams.options = optimset('Algorithm','sqp', 'Display', 'off');
fitparams.model = @gtcmodel;

% jitter the starting values from the ln model
fitparams.x0fun = {@() gainmodel.params(1)*(.95+(rand*.1)) ...
            @() gainmodel.params(2)*(.95+(rand*.1)) ...
            @() gainmodel.params(3)*(.95+(rand*.1)) ...
            @() gainmodel.params(4)*(.95+(rand*.1)) ...
            @() gainmodel.params(5)*(.95+(rand*.1)) ...
            @() gainmodel.params(6)*(.95+(rand*.1)) ...
            @() rand*100};

fitparams.params = {[], [], [], [], [0 0 -Inf -Inf 0 0], [], []};

lb = [0 0 -Inf -Inf 0 0 0];
ub = [+Inf +Inf +Inf +Inf +Inf +Inf +Inf];

fp.params = {[], [], [], [], lb, ub, []};

model = fitmodel3(fitparams, fitdata);
