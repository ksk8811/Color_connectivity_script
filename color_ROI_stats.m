function [rm_anova_results,t_test_results] = color_ROI_stats (data)

% load a table with responses in the conditions in a given ROI. The columns
% are the condition, the rows are the subjects. One table per one ROI.



subject = 1:height(data);

%color and shape anova
color_and_shape = data(:, 2:5);
T = stack(color_and_shape,1:4,...
    'NewDataVariableName','Reponse',...
    'IndexVariableName','Condition');
T.color = cellfun(@(x) contains(x, 'color'), cellstr(T.Condition));
T.shape = cellfun(@(x) contains(x, 'object'), cellstr(T.Condition));
colShape_within_factors = T(1:4, 3:4);



rm = fitrm(color_and_shape,'object_good_color-mondirans_grey_scale~1','WithinDesign',colShape_within_factors)
[rm_anova_results] = ranova(rm, 'WithinModel','color*shape')

%object t-test

[h,p,ci,stats] = ttest(data{:,2}, data{:,1});
t_test_results = {h, p, ci(1), ci(2), stats.tstat, stats.df, stats.sd};
end

