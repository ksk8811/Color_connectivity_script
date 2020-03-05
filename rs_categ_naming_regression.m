% open color_connectivity.mat project, go to first level and choose bivariate
% correlations, then go to second level/ROI to ROI analysis, and choose a
% seed and targets.Then go to plot effect. It will create a wariable
% "Effect_values" in your worksspace. For the behavioural values, go to /Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/color_rs_connectivity/behavioral_corelates  

addpath /Users/k.siudakrzywicka/Desktop/RDS_fMRI/RDS_localizers/scripts
cd /Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/color_rs_connectivity/behavioral_corelates

%locate subject numbers
subs = dir('/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/Processed_566_471_vol');
subs = {subs.name};
subs = cellfun(@str2double,subs(4:end));
subs = subs-1000;
subs = subs(1:end-6); %take out aditional 6 women

naming_categ = readtable('color_categorization_naming_2ndBlock.xlsx');
partial = naming_categ{:, [2,3]};


% naming_categ = naming_categ(3:end, :); %take out the patient
% naming_categ.no = naming_categ.no - 1;
% naming_categ = naming_categ(ismember(naming_categ.no,subs), :);
% 
% naming = naming_categ(strcmp(naming_categ.task, 'CN'), :);
% categ = naming_categ(strcmp(naming_categ.task, 'CC'), :);

behavior = naming_categ{:,7 };


%%
connectivity = [-0.0437327 0.204121 0.214168 0.144569 0.0979717 0.143297 0.256646 -0.0461484 0.137161 -0.32824 -0.059902 0.16525 0.134405 0.0968771 -0.0139668 NaN -0.0364638 0.0962955 0.148974 NaN;
    -0.102643 0.126645 0.303922 0.118971 0.184869 0.124062 0.249373 -0.0807016 0.269338 -0.281279 -0.0281272 -0.000114652 0.0118272 0.107977 -0.0376007 NaN -0.0250033 0.214788 0.170565 NaN]';
% connectivity values come from import values in CONN, you can find them in
% set up->second level covariates. for details see HOWTO_connectivity_and_behavior_correlations.docx 

to_corr = [behavior, connectivity];
[to_corr, idx] = rmmissing(to_corr);

%[RHO,PVAL] = corr(to_corr);
[RHO,PVAL] = partialcorr(to_corr, partial(~idx,:));
signiticant = RHO.*(PVAL<=0.05);

%%
names = {'naming_RT'};
% 
% 
% targets = cellfun(@strsplit, Effect_names, 'UniformOutput', 0);
% target_names = cell(1, length(targets));
% 
% for i = 1:length(targets)
%     if length(targets{i}) == 9
%         
%         target_names{i} = targets{i}{4};
%     else
%         target_names{i} = strcat(targets{i}{4}, '_' , targets{i}{5})
%     end
% end
% 
% target_names = strrep(target_names, '.', '_');
% [~, ind] = unique(target_names);
% 
% duplicate_ind = setdiff(1:length(target_names), ind);
% 
% if ~isempty(duplicate_ind)
%     for i = 1:length(duplicate_ind)
%     target_names(duplicate_ind(i)) = strcat(target_names(duplicate_ind(i)), num2str(i));
%     end
% end
%     
%     
% % targets = cellfun(@(x) strcat(x(4), '_', x(5)), targets);
% 
% effect_values = array2table(Effect_values, 'VariableNames', target_names);
target_names = {'aMTG_L', 'pMTG_L'}
names = [names, target_names];

pval_results = array2table(PVAL, 'VariableNames', names, 'RowNames', names);
rho_results = array2table(RHO, 'VariableNames', names, 'RowNames', names);


significant_results = array2table(signiticant, 'VariableNames', names, 'RowNames', names);
% %%
% writetable(pval_results, 'right_OF_pval.xlsx');
% writetable(rho_results, 'right_OF_rho.xlsx');

%% corrs with task fMRI

% taskMRI = readtable('/Users/k.siudakrzywicka/Desktop/leftOF-t-fMRI.xlsx');
% 
% [rho, pval] = corr(naming.RT, taskMRI.mondrian_color(1:14));
% 
% 

%%

%figures


% figure
% subplot(1,2,1)
% scatter(categ.RT, connectivity(1:end-6,3), 100, [0.4660 0.6740 0.1880], 'filled')
% % hold on 
% % Fit = polyfit(categ.RT, connectivity(1:end-6,3),1); 
% % plot(polyval(Fit,linspace(0,4,4)))
% ylabel('connectivity (Fisher r to z)')
% xlabel('RT (in seconds)')
% title ('Categorisation and right MTG')
% 
% % subplot(1,2,2)
% scatter(categ.RT, connectivity(1:end-6,5), 100, [0.4660 0.6740 0.1880], 'filled')
% % hold on 
% % Fit = polyfit(categ.RT, connectivity(1:end-6,5),1); 
% % plot(polyval(Fit,linspace(0,4,4)))
% xlabel('RT (in seconds)')
% title ('Categorisation and left MTG')
%

% for f = 1:length(Effect_names)
%     
%     figure('Units', 'inches')
%     % subplot(1,2,1)
%     data = effect_values{:,f}{:};
%     h = scatter(naming.RT, data(1:14), 100, [0.8500 0.3250 0.0980], 'filled');
%     axes1 = gca;
%     xlimits = xlim;
%     xplot1 = linspace(xlimits(1), xlimits(2));
% 
% 
%     fitResults1 = polyfit(h.XData,h.YData,1);
%     yplot1 = polyval(fitResults1,xplot1);
% 
%     hold on
% 
%     fitLine1 = plot(xplot1,yplot1,'DisplayName','   linear','Tag','linear',...
%         'Parent',axes1,...
%         'Color',[0.929 0.694 0.125]);
% 
%     % Set new line in proper position
%     setLineOrder(axes1,fitLine1,h);
% 
%     % hold on 
%     % Fit = polyfit(naming.RT, connectivity(1:end-6,5),1); 
%     % plot(polyval(Fit,linspace(0,4,4)))
%     ylabel('connectivity (Fisher r to z)')
%     xlabel('RT (in seconds)')
%     tlt = ['Naming: left OF - ' target_names{f} '; r=' num2str(round(rho_results{2,f+4},2)) ' p=' num2str(round(pval_results{2,f+4},3))];
%     title (tlt)
% 
%     plot2pdf(['Naming: left OF - ' target_names{f} ])
% end

figure
h = scatter(to_corr(:,1), to_corr(:,75), 100, [0.8500 0.3250 0.0980], 'filled');
    axes1 = gca;
    xlimits = xlim;
    xplot1 = linspace(xlimits(1), xlimits(2));


    fitResults1 = polyfit(h.XData,h.YData,1);
    yplot1 = polyval(fitResults1,xplot1);

    hold on

    fitLine1 = plot(xplot1,yplot1,'DisplayName','   linear','Tag','linear',...
        'Parent',axes1,...
        'Color',[0.929 0.694 0.125]);

    % Set new line in proper position
    setLineOrder(axes1,fitLine1,h);

    % hold on 
    % Fit = polyfit(naming.RT, connectivity(1:end-6,5),1); 
    % plot(polyval(Fit,linspace(0,4,4)))
    ylabel('beta')
    xlabel('RT (in seconds)')
    tlt = 'left OF:left aMTG x Naming RT';
    title (tlt)

    plot2pdf(tlt)

    % subplot(1,2,2)
    % scatter(naming.RT, connectivity(1:end-6,5), 100, [0.8500 0.3250 0.0980], 'filled')
    % % hold on 
    % % Fit = polyfit(naming.RT, connectivity(1:end-6,5),1); 
    % % plot(polyval(Fit,linspace(0,4,4)))
    % title ('Naming and left MTG')

%-------------------------------------------------------------------------%
function setLineOrder(axesh1, newLine1, associatedLine1)
%SETLINEORDER(AXESH1,NEWLINE1,ASSOCIATEDLINE1)
%  Set line order
%  AXESH1:  axes
%  NEWLINE1:  new line
%  ASSOCIATEDLINE1:  associated line

% Get the axes children
hChildren = get(axesh1,'Children');
% Remove the new line
hChildren(hChildren==newLine1) = [];
% Get the index to the associatedLine
lineIndex = find(hChildren==associatedLine1);
% Reorder lines so the new line appears with associated data
hNewChildren = [hChildren(1:lineIndex-1);newLine1;hChildren(lineIndex:end)];
% Set the children:
set(axesh1,'Children',hNewChildren);
end
