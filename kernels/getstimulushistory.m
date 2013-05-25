function X_fht = getstimulushistory(X_ft, dt, bins)
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
	  X_fht(:, n_h+1-h_idx, t_idx) = sum(X_ft(:, max(mn,1):mx), 2);
	end
  end
end
