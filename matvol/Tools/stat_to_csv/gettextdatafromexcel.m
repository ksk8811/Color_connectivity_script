function xlsdata=gettextdatafromexcel(excelfile,columnname)
%%%% recovers a column of text data with name "columnname"
%%%% from an excel file named "excelfile"

warning('off','MATLAB:xlsread:Mode');

[datanum,datatext]=xlsread(excelfile);
xlscoloffset = size(datatext,2)-size(datanum,2);

f=find(strcmp(datatext,columnname));  %%% 
if isempty(f)
    error('No variable named %s in excel file %s',columnname,excelfile);
else
    [a,b]=ind2sub(size(datatext),f(1));
    xlsdata=datatext(2:end,b);
    
    for i=1:length(xlsdata)
        if isempty(xlsdata{i})
            xlsdata{i}=num2str(datanum(i,b-xlscoloffset));
        end
    end
end