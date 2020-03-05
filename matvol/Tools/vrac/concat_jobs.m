function jobo=concat_jobs(job,nbconcat)

numj = 1;
cmdd='';
jobo='';

while numj<=length(job)
    cmdd = sprintf('%s\n%s',cmdd,job{numj});
    if mod(numj,nbconcat)==0
        jobo{end+1} = cmdd;
        cmdd='';
    end
    numj=numj+1;
end
