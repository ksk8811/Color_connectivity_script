% open color_connectivity.mat project, go to first level and choose bivariate
% correlations, then go to second level/ROI to ROI analysis, and choose a
% seed and targets.Then go to plot effect. It will create a wariable
% "Effect_values" in your worksspace. For the behavioural values, go to /Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/color_rs_connectivity/behavioral_corelates  


%locate subject numbers
clear
clc

subs = dir('/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/Processed_566_471_vol');
subs = {subs.name};
subs = cellfun(@str2double,subs(4:end));
subs = subs-1000;
subs = subs(1:end-6); %take out aditional 6 women

memo = readtable('color_memory.xlsx');

memo = memo(3:end, :); %take out the patient
memo.Subject = memo.Subject - 1000;
memo = memo(ismember(memo.Subject,subs), :);

memo_on = memo(strcmp(memo.Condition, 'On'), :);
memo_split = memo(strcmp(memo.Condition, 'Sep'), :);

behavior = [memo_on.RT, memo_split.RT];

%%
connectivity = [Effect_values{:}];

to_corr = [behavior, connectivity(1:8, :)];

[RHO,PVAL] = corr(to_corr, 'type', 'spearman');
names = {'memo_on_RT', 'memo_split_RT'};

targets = cellfun(@strsplit, Effect_names, 'UniformOutput', 0);
target_names = cell(1, length(targets));

for i = 1:length(targets)
    if length(targets{i}) == 9
        
        target_names{i} = targets{i}{4};
    else
        target_names{i} = strcat(targets{i}{4}, '_' , targets{i}{5})
    end
end

names = [names, target_names];

pval_results = array2table(PVAL, 'VariableNames', names, 'RowNames', names);
rho_results = array2table(RHO, 'VariableNames', names, 'RowNames', names);

signiticant = RHO.*(PVAL<=0.05);
significant_results = array2table(signiticant, 'VariableNames', names, 'RowNames', names);
%%
writetable(pval_results, 'right_CF_pval.xlsx');
writetable(rho_results, 'right_CF_rho.xlsx');
%%

%figures


figure
subplot(1,2,1)
scatter(categ.RT, connectivity(1:end-6,3), 100, [0.4660 0.6740 0.1880], 'filled')
% hold on 
% Fit = polyfit(categ.RT, connectivity(1:end-6,3),1); 
% plot(polyval(Fit,linspace(0,4,4)))
ylabel('connectivity (Fisher r to z)')
xlabel('RT (in seconds)')
title ('Categorisation and right MTG')

subplot(1,2,2)
scatter(categ.RT, connectivity(1:end-6,5), 100, [0.4660 0.6740 0.1880], 'filled')
% hold on 
% Fit = polyfit(categ.RT, connectivity(1:end-6,5),1); 
% plot(polyval(Fit,linspace(0,4,4)))
xlabel('RT (in seconds)')
title ('Categorisation and left MTG')

figure
% subplot(1,2,1)
scatter(naming.RT, connectivity(1:end-6,3), 100, [0.8500 0.3250 0.0980], 'filled')
% hold on 
% Fit = polyfit(naming.RT, connectivity(1:end-6,5),1); 
% plot(polyval(Fit,linspace(0,4,4)))
ylabel('connectivity (Fisher r to z)')
xlabel('RT (in seconds)')
title ('Naming and left MTG')

subplot(1,2,2)
scatter(naming.RT, connectivity(1:end-6,5), 100, [0.8500 0.3250 0.0980], 'filled')
% hold on 
% Fit = polyfit(naming.RT, connectivity(1:end-6,5),1); 
% plot(polyval(Fit,linspace(0,4,4)))
title ('Naming and left MTG')

