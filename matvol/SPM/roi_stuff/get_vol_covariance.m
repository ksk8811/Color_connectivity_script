function [allmean_cov indV indS indallV] =  get_vol_covariance(V,numstd,first_slice)

n = length(V);
vol = zeros(prod(V(1).dim(1:2)), n);
YpY = zeros(n);
YpYvol = zeros(n);

indS=[]; indV=[];

for j=first_slice:(V(1).dim(3))
%for j=1:V(1).dim(3)

  M  = spm_matrix([0 0 j]);

  for i = 1:n
    img = spm_slice_vol(V(i),M,V(1).dim(1:2),[1 0]);
    vol(:,i) = img(:);
  end


  mean_slice = mean(reshape(vol,[V(i).dim(1:2) n]),3);
  mask = find(mean_slice ~= 0 & ~isnan(mean_slice));

  % remove nuisance and calculate again mean
  %if ~isempty(nuisance) 
  %  vol(mask,:) = vol(mask,:) - vol(mask,:)*pinv(nuisance)*nuisance;
  %end

  if ~isempty(mask)
    % make sure data is zero mean
    tmp_vol = vol(mask,:);
    tmp_vol = tmp_vol - repmat(mean(tmp_vol,1), [length(mask) 1]);
    YpY = (tmp_vol'*tmp_vol)/n;
    YpYvol = YpYvol + (tmp_vol'*tmp_vol)/n;
  end 


  % normalize YpY
  d = sqrt(diag(YpY)); % sqrt first to avoid under/overflow
  dd = d*d';
  YpY = YpY./(dd+eps);
  t = find(abs(YpY) > 1); 
  YpY(t) = YpY(t)./abs(YpY(t));
  YpY(1:n+1:end) = sign(diag(YpY));

  % extract mean covariance
  mean_cov = zeros(n,1);
  for i=1:n
    % extract row for each subject
    cov0 = YpY(i,:);
    % remove cov with its own
    cov0(i) = [];
    mean_cov(i) = mean(cov0);
  end

  threshold_cov = mean(mean_cov) - numstd*std(mean_cov);
  
  threshold_cov = mean(mean_cov) - numstd*mean(mean_cov);
  
  
  % print suspecious files with cov>0.9
%  YpY_tmp = YpY - tril(YpY);
%  [indx, indy] = find(YpY_tmp>0.9);
%  if ~isempty(indx) & (sqrt(length(indx)) < 0.5*n)
%    fprintf('\nUnusual large covariances (check that subjects are not identical):\n');
%    for i=1:length(indx)
%      % exclude diagonal
%      if indx(i) ~= indy(i)
%	% report file with lower mean covariance first
%	if mean_cov(indx(i)) < mean_cov(indy(i))
%	  fprintf('%s and %s: %3.3f\n',fname.m{indx(i)},fname.m{indy(i)},YpY(indx(i),indy(i)));
%	else
%	  fprintf('%s and %s: %3.3f\n',fname.m{indy(i)},fname.m{indx(i)},YpY(indy(i),indx(i)));
%	end
%      end
%    end
%  end

  % sort files
%  fprintf('\nMean covariance for data below 2 standard deviations For Slice %d :\n',j);
  [mean_cov_sorted, ind] = sort(mean_cov,'descend');
  n_thresholded = min(find(mean_cov_sorted < threshold_cov));
  
  for i=n_thresholded:n
%    fprintf('%s: %3.3f\n',V(ind(i)).fname,mean_cov_sorted(i));
    indS = [indS j];
    indV = [indV ind(i)];
  end

  allmean_cov(:,j) = mean_cov;
end

  % normalize YpYvol
  d = sqrt(diag(YpYvol)); % sqrt first to avoid under/overflow
  dd = d*d';
  YpYvol = YpYvol./(dd+eps);
  t = find(abs(YpYvol) > 1); 
  YpYvol(t) = YpYvol(t)./abs(YpYvol(t));
  YpYvol(1:n+1:end) = sign(diag(YpYvol));

  % extract mean covariance
  mean_cov = zeros(n,1);
  for i=1:n
    % extract row for each subject
    cov0 = YpYvol(i,:);
    % remove cov with its own
    cov0(i) = [];
    mean_cov(i) = mean(cov0);
  end

  threshold_cov = mean(mean_cov) - numstd*std(mean_cov);

  % sort files
%  fprintf('\nMean covariance for data below 2 standard deviations For Slice %d :\n',j);
  [mean_cov_sorted, ind] = sort(mean_cov,'descend');
  n_thresholded = min(find(mean_cov_sorted < threshold_cov));
  
  indallV =ind;

  allmean_cov_allV = mean_cov;
%keyboard