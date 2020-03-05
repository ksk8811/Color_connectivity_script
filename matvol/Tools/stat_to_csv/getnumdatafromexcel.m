function xlsdata=getnumdatafromexcel(excelfile,columnname)
%%%% recovers a column of numerical data with name "columnname"
%%%% from an excel file named "excelfile"

warning('off','MATLAB:xlsread:Mode');

[datanum,datatext]=xlsread(excelfile);
xlscoloffset = size(datatext,2)-size(datanum,2);

f=find(strcmp(datatext,columnname));  %%% 
if isempty(f)
    error('No variable named %s in excel file %s',columnname,excelfile);
else
    [a,b]=ind2sub(size(datatext),f(1));
    xlsdata=datanum(:,b-xlscoloffset);
end
