
clear
%note that con files for condition vs rest have the same values as betas !
%so no difference between con and beta tables for the ROIs


%cd('/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/colorRegions_rois/from_secondLevel_peaks/color-regions-p001corr/final/8mmspheres');


% if beta 
%     
%     
% tabs = dir('bin_*50*beta.xlsx');
% tabs = {tabs.name};
% 
% conTab = readtable('megaTable_bin_best_50vox_spmT_0001_confiles.csv');
% template = conTab;
% 
% for t = 1%:length(tabs)
%     
%     T = readtable(tabs{t});
%     T = T(:, [1 5 2 4 3]);
% 
%     
%     template{:,(t-1)*5+1:t*5}= table2array(T);
%       
% end



    
    %tabs = dir('bin_*50*con.xlsx');
    tabs = dir('bin_*.xlsx');
    tabs = {tabs.name};
    
megaTable = zeros(20, 5*length(tabs));


colNames = cell(1, 5*length(tabs));

for t = 1:length(tabs)
    
    T = readtable(tabs{t});
    T = T(:, [1 5 2 4 3]);
  
   
    
    names_idx = strfind(tabs{t}, '_');
    side_idx = names_idx(8:9);
    name_idx = names_idx(7:8);
    
    
    name = tabs{t}(name_idx(1)+2:name_idx(2)-1);
    side = tabs{t}(side_idx(1)+1:side_idx(2)-1);
 
    
    megaTable(:,(t-1)*5+1:t*5)= table2array(T);
    colNames(1, (t-1)*5+1:t*5) = strcat([name '_' side '_' ], T.Properties.VariableNames);
      
end

megaTable = array2table(megaTable, 'VariableNames',colNames);
writetable(megaTable, 'megaTable_bin_best_50vox_spmT_0001_confiles.csv')
