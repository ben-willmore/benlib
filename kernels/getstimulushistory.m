function [X_fht, t] = getstimulushistory(X_ft, dt, bins, dt_new, type)
% function X_fht = getstimulushistory(X_ft, dt, bins)
% 
% Add a history dimension to a stimulus matrix, using non-uniform bins
% Inputs:
%  X_ft -- stimulus matrix, freqs x time
%  dt   -- the time between bins in the stimulus matrix
%  bins -- the desired non-uniform history bins
% 
% Outputs:
%  X_fht -- stimulus matrix with non-uniformly sampled history

if ~exist('dt_new', 'var')
	dt_new = dt;
end

if ~exist('type', 'var')
	type = 'sum';
end

[n_f, n_t] = size(X_ft);
n_h = length(bins)-1;

% work out which spectrogram bins will go into each logspaced bin
idx = round(bins/dt);

X_fht = zeros(n_f, n_h, n_t);
for t_idx = 1:n_t
  for h_idx = 1:n_h
  	mn = t_idx-idx(h_idx+1)+1;
  	mx = t_idx-idx(h_idx);

  	if mx>0
  	  if strcmp(type, 'sum')
	    X_fht(:, n_h+1-h_idx, t_idx) = sum(X_ft(:, max(mn,1):mx), 2);
	  elseif strcmp(type, 'mean')
	    X_fht(:, n_h+1-h_idx, t_idx) = sum(X_ft(:, max(mn,1):mx), 2);
      else
      	error('unknown type -- should be mean or sum')
      end
	end
  end
end

if mod(dt_new, dt)~=0
  error('getstimulushistory only implemented for dt_new an integer multiple of dt');
elseif dt_new~=dt
  step = dt_new/dt;
  X_fht = X_fht(:, :, 1:step:end);
  t = (1:size(X_fht, 3))-1;
  t = t*dt;
end