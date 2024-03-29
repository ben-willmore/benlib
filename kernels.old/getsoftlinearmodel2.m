function model = getsoftlinearmodel(z_fit, y_fit)
% function model = getlnmodel(z_fit, y_fit)
% Modified by Joe to use fitmodel4_minFunc

% a = x(1); % y-offset
% b = x(2); % slope
% c = x(3); % x-offset
% d = x(4); % sharpness of transition

fitdata.y_t = y_fit;
fitdata.z_t = z_fit;

% initialise fit params
fitparams.restarts = 5;
fitparams.options = optimset('Algorithm', 'sqp', 'Display', 'off');
fitparams.model = @softlinearmodel;
fitparams.errorfunc = @softlinearerror;

% data driven starting values (could also be used as priors)
% zrange = iqr(z_fit);
% if zrange==0
%   zrange = 0.001;
% end
% zmean = mean(z_fit);
% yrange = iqr(y_fit);
% ymin = prctile(y_fit, 5);
% ymax = max(y_fit); %prctile(y_fit, 95);
% zmin = prctile(z_fit, 5);
% zmax = prctile(z_fit, 95);

%zmax = prctile(z_fit, 95);

%a ~ Exp(ymin + 0.05) 
%b ~ Exp(yrange * 2) % not using *2
%c ~ N(zmean, zrange ^ 2)
%d ~ Exp(0.1 * zrange) (minimum at 0.1)
%fitparams.x0fun = {@() exprnd(ymin) @() exprnd(yrange/zrange) ...
%       			     @() rand*(zmax-zmin)+zmin @() exprnd(100/(zmax-zmin))};

% a = x(1); % y-offset
% b = x(2); % slope
% c = x(3); % x-offset
% d = x(4); % sharpness of transition

ymin = prctile(y_fit, 2);
ymax = prctile(y_fit, 98);
yrange = prctile(y_fit, 98)-prctile(y_fit, 2);
zmin = prctile(z_fit, 2);
zmax = prctile(z_fit, 98);
z50  = prctile(z_fit, 50);
zrange = zmax-zmin;
slope = (prctile(y_fit, 98)-prctile(y_fit, 90))/(prctile(z_fit, 98)-prctile(z_fit, 90));
%keyboard
fitparams.x0fun = { @() ymin+randn*0.1*yrange ... % y-offset
					@() slope*(1+0.2*randn) ... % slope
       			    @() z50+randn*0.5*zrange ... % x-offset of transition
       			    @() exprnd(100/(zmax-zmin))}; % sharpness of transition

% for jj = 1:length(fitparams.x0fun)
%     x0(jj) = fitparams.x0fun{jj}();
% end
% x0

%[ymin+0.05 3*yrange/zrange zmax yrange]
% constraints
% y_min = min(y_fit);
% y_max = max(y_fit);
% y_range = range(y_fit);
% z_min = min(z_fit);
% z_max = max(z_fit);
% z_range = range(z_fit);

% bounds are intended to be rather generous
%lb = [y_min-3*y_range 0 z_min-3*z_range]; % lower bounds
%ub = [y_max+3*y_range 10*y_range z_max+3*z_range]; % upper bounds
%lb = [1 0 -1000 10];
%ub = [1 1000 1000 1000];
lb = [0 slope/10 ymin 0];
ub = [ymax slope*10 ymax zmax-zmin];

%fitparams.params = {[], [], [], [], lb, ub, []};
fitparams.params = {[], [], [], [], lb, ub, []};

model = fitmodel5_minFunc(fitparams, fitdata);

% if any(abs(model.params-lb)<eps)
% 	fprintf('getlnmodel: hit lower bounds:\n');
% 	model.params
% 	lb
% end
% 
% if any(abs(model.params-ub)<eps)
% 	fprintf('getlnmodel: hit upper bounds\n');
% 	model.params
% 	ub
% end
