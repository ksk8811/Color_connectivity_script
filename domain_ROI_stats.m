function [rm_anova_results,anova_post_hoc, t_test_results] = domain_ROI_stats (data)

% load a table with responses in the conditions in a given ROI. The columns
% are the condition, the rows are the subjects. One table per one ROI.

subject = 1:height(data);

%within_factor = cell2table(data.Properties.VariableNames',  'VariableNames', {'class'});
%

within_factor = cell2table({'Symbolic', 'Symbolic', 'Living', 'Living', 'Man-made','Man-made'}',  'VariableNames', {'class'});
within_factor.class = categorical(within_factor.class);


rm = fitrm(data,'numbers-tools~1','WithinDesign',within_factor);
[rm_anova_results] = ranova(rm, 'WithinModel','class');

anova_post_hoc = multcompare(rm, 'class')

%object t-test

[h,p,ci,stats] = ttest(table2array(data),0, 'Alpha',0.05/6);
t_test_results = [h', p', ci(1,:)', ci(2,:)', stats.tstat', stats.df', stats.sd'];
t_test_results = array2table(t_test_results,...
        'VariableNames',{'h1','p', 'lower_ci', 'upper_ci', 't', 'df', 'sd'});
end