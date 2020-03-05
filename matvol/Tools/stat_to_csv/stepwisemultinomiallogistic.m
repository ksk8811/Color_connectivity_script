function [inmodel,history,select_order] = stepwisemultinomiallogistic(x,Y,norm,seuil)

%x=values  %sujet*region
%y=groupe

p = 1-seuil;
miter = 5000; 

% Read input / norm
[n m] = size(x);
if ~exist('norm','var'), norm = 0; end
if norm==1,x=(x-repmat(nanmean(x),size(x,1),1))./repmat(nanstd(x),size(x,1),1); end

% opts
maxdev = chi2inv(p,1)/2;
opt = statset('display','iter','TolFun',maxdev,'MaxIter',miter,'TolTypeFun','abs');

% Fit a logistic regression model using all predictors
%[b0,dev0,stats0] = mnrfit(x,Y,'estdisp','on');
%model0 = [b0 stats0.se stats0.p];
%disp('Full model')
%disp([model0])
%disp(dev0)
%disp('Classif')
%disp(glmval(b0,x,'logit'))

% Use sequential feature selection to order the features according to how much they contribute to the model
[inmodel,history] = sequentialfs(@fitter,x,Y,'cv','none','nullmodel',true,'direction','forward','options',opt);

select_order=[];

for k=2:size(history.In,1)
  aa = history.In(k,:)-history.In(k-1,:);
  select_order(k-1) = find(aa);
end

 
% Under the null hypothesis 2*deviance has a chi-square distribution, so
% we'll take the chi-square cutoff and divide by 2.
dev = history.Crit; % set of deviance values for all models
deltadev = -diff(dev); % deviance improvement for each step
nfeatures = find(deltadev>maxdev,1,'last');
if isempty(nfeatures), nfeatures = 0; in = false(1,m);
else in = logical(history.In(nfeatures,:));
end

% Plot all deviance values and mark the one we'd select
%figure,hold on
%plot(dev(2:end),'b-x'), plot(nfeatures,dev(nfeatures+1),'ro')
%xlabel('Number of predictors'); ylabel('Deviance')
%[b,dev,st] = mnrfit(x(:,in),Y);

% Display the coefficients for the selected model
%B = zeros(4,m+1);
%B(1:2,[true,in]) = b';
%B(3:4,[true,in]) = st.se';
%disp('Reduced model')
%disp(B)

% Final model
%[b,dev,stats] = mnrfit(x(:,inmodel),Y,'estdisp','on');
%model = [b stats.se stats.p];
%disp('Final model')
%disp([model])
%disp(dev)
%disp('Classif')
%disp(mnrval(b,x(:,inmodel)))


function dev = fitter(x,y)
warning off
[b,dev] = mnrfit(x,y,'estdisp','on','model','ordinal');
warning on
