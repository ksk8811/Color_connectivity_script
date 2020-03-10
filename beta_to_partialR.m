function r = beta_to_partialR(model, x1)
%beta_to_partialR is a matlab script that converts multiple regression beta
%coefficients to partial r . The formula and rationale come from this post:
%https://stats.stackexchange.com/questions/76815/multiple-regression-or-partial-correlation-coefficient-and-relations-between-th
%by Kirill Orlov http://spsstools.net/en/macros/KO-aboutauthor/
%Briefly:
% r(yx1.X) = beta(x1) * sqrt(var(residuals from regressing x1 by X/var(resuduals from regressing y by X))) where 
% y is the dependent variable, and X stands for the collection of all predictors except x1

%   model - model from which comes the B
%   x1 - predictor of interest
%   

vars = model.Variables;
y = model.ResponseName;
X = model.PredictorNames(~contains(model.PredictorNames, x1));
X_formula = strjoin(X, '+');

beta_index = contains(model.CoefficientNames, x1);

beta = model.Coefficients.Estimate(beta_index);


model_y_by_X = fitlm(vars,[y '~' X_formula]);
model_x1_by_X = fitlm(vars, [x1 '~' X_formula]);


r = beta*sqrt(var(model_x1_by_X.Residuals.Raw/var(model_y_by_X.Residuals.Raw)))

end

