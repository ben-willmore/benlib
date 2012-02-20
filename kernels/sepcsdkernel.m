function kernel = separablecsdkernel(X_fht, y_dt, niter)
% function kernel = separablecsdkernel(X_fht, y_dt, niter)
% 
% Compute separable CSD kernel (one freq profile per depth plus
% one inseparable history x depth kernel)
%
% Inputs:
%  X_fht -- tensorized stimulus, freq x history x time
%  y_dt -- CSD, depth x time
%  niter -- number of iterations to run for
% 
% Output:
%  kernel.k_f -- frequency kernel
%  kernel.k_hd -- history x depth kernel kernel
%  kernel.c_f -- constant term for freq
%  kernel.c_d -- constant term for depth

  if ~exist('niter', 'var')
    niter = 15;
  end

  X_fht(end+1, end+1, :) = 1;

  fprintf('Calculating kernel');  
  [n_f, n_h, n_t] = size(X_fht);

  n_d = size(y_dt, 1);
  n_hd = n_h * n_d;

  k_f = ones(n_f, 1);
  k_hd = ones(n_h, n_d);
  
  X_fh1t = reshape(X_fht,[n_f, n_h, 1, n_t]);

  y_td_unwrap = y_dt(:);

  %fprintf('Starting\n');
  %evalfit(k_f, k_hd, X_fht, y_dt);

  for ii = 1:niter
    fprintf('.');

    % multiply by history/depth kernel and sum over history
    k_1hd = shiftdim(k_hd, -1);
    keyboard
    a_fhdt = repmat(X_fh1t, [1 1 n_d 1]) .* repmat(k_1hd, [n_f 1 1 n_t]);
    a_f1dt = sum(a_fhdt, 2);
    
    % optimise k_f
    %k_f = lsqlin(reshape(a_f1dt,[n_f n_d*n_t])', y_t(:));
    a_td_f = reshape(a_f1dt, [n_f n_d*n_t])';
    k_f = a_td_f\y_td_unwrap;
    
    % force k_f to be positive
    k_f = k_f*sign(mean(k_f(1:end-1)));

    %fprintf('Finished fitting k_f\n');
    %evalfit(k_f, k_hd, X_fht, y_dt);
  
    % multiply by frequency kernel and sum over frequency
    b_fhdt = X_fh1t .* repmat(k_f, [1 n_h 1 n_t]);
    b_1hdt = sum(b_fhdt, 1);
    b_ht = reshape(b_1hdt(:,:,1,:), [n_h n_t]);
  
    % optimise the history kernels for each depth separately
    for jj = 1:n_d
      y_t_jj = y_dt(jj,:);
      k_hd(:,jj) = b_ht'\y_t_jj';
      %k_hd(:,jj) = lsqlin(b_ht', y_t(jj,:)');
    end

    %fprintf('Finished fitting k_hd\n');
    %evalfit(k_f, k_hd, X_fht, y_dt);

    % subplot(1,2,1);plot(k_f(1:end-1));
    % mx = max(abs(k_hd(:)));
    % subplot(1,2,2);imagesc(fliplr(k_hd'), [-mx mx]);
    % colormap(colormap_redblackblue);
    % drawnow;

  end

  % separate out constant terms
  kernel.c_f = k_f(end);
  kernel.k_f = k_f(1:end-1);

  kernel.c_d = k_hd(end, :);
  kernel.k_hd = k_hd(1:end-1, :);
  
  fprintf('done\n');  

