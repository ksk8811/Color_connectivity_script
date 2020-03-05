function dti_import(dti_files,bval_f,bvec_f,dti_dir,par)

if ~exist('par')
    par='';
end



if ~isfield(par,'skip_vol'),  par.skip_vol=''; end

if ~isfield(par,'sge'),  par.sge=0; end
if ~isfield(par,'queu'),  par.queu = 'server_ondule';end
if ~isfield(par,'dirjob'),  par.dirjob = pwd ;end
if ~isfield(par,'data4D'),    par.data4D = '4D_dti';  end
if ~isfield(par,'dicom_info') ,par.dicom_info='';end

if iscell(dti_dir)
    for k=1:length(dti_dir)
        dti_import(dti_files{k},bval_f{k},bvec_f{k},dti_dir{k},par)
    end
    return
end


bval_f=cellstr(char(bval_f));
bvec_f=cellstr(char(bvec_f));

if iscell(dti_files)
    dti_files = char(dti_files);
end
%remove skiping volume
if ~isempty(par.skip_vol)
    dti_files(par.skip_vol,:)='';
end

if ~exist(dti_dir)
    mkdir(dti_dir)
end

cwd = pwd;
cd(dti_dir)

    

%DO MERGE
cmd =sprintf(' fslmerge  -t %s ',par.data4D);

for k=1:size(dti_files,1)
    cmd = [cmd ' ' dti_files(k,:) ];
end

if par.sge
    fprintf(fj,cmd);fprintf(fj,'\n');
else
    unix(cmd)
end


bval=[];bvec=[];
for k=1:length(bval_f)
    aa = load(deblank(bval_f{k}));
    bb = load(deblank(bvec_f{k}));
    bval = [bval aa];
    bvec = [bvec,bb];
end

%remove skiping volume
if ~isempty(par.skip_vol)
    bval(:,par.skip_vol)=[];
    bvec(:,par.skip_vol)=[];
end

if isempty(par.dicom_info)
   %keyboard
end

if ~isempty(par.dicom_info)
    fid = fopen(fullfile(dti_dir,'acqp.txt'),'w');
    for k = 1:length(par.dicom_info)
        h = par.dicom_info(k);
        hsession(k) = h.SeriesNumber;        
        phase_angle = str2num(h.phase_angle);
        if isempty(phase_angle), phase_angle = 0;end
        switch h.PhaseEncodingDirection
            case 'COL '
                if phase_angle<0.1
                    fprintf(fid,'0 -1 0 0.050\n');
                elseif abs(phase_angle-pi)<0.1
                    fprintf(fid,'0 1 0 0.050\n');
                else
                    error('what is the Y phase direciton <%f> in you  dicom!',phase_angle)
                end
            case 'ROW '
                if abs(phase_angle-pi/2)<0.1
                    fprintf(fid,'-1 0 0 0.050\n');
                elseif abs(phase_angle+pi/2)<0.1
                    fprintf(fid,'1 0 0 0.050\n');
                else
                    error('what is the phase direciton in you fucking dicom!')
                end
                
            otherwise
                error('what is this phase axe <%s>', h.PhaseEncodingDirection)
        end
        
    end
    
    fclose(fid);
    [aa bb cc]= unique(hsession);
    fid = fopen(fullfile(dti_dir,'session.txt'),'w');
    fprintf(fid,'%d ',cc);
    fclose(fid);
    
    fid = fopen(fullfile(dti_dir,'index.txt'),'w');
    fprintf(fid,'%d ',1:length(par.dicom_info));
    fclose(fid);
 
end
%Writing bvals and bvec

fid = fopen(fullfile(dti_dir,'bvals'),'w');
fprintf(fid,'%d ',bval);  fprintf(fid,'\n');  fclose(fid);

fid = fopen(fullfile(dti_dir,'bvecs'),'w');
for kk=1:3
    fprintf(fid,'%f ',bvec(kk,:));
    fprintf(fid,'\n');
end
fclose(fid);



if par.sge
    fclose(fj);
    fprintf('writing job %s\n',jname);
    
    qsubname = fullfile(par.dirjob,'do_qsub.sh');
    
    if ~exist(qsubname)
        fqsub = fopen(qsubname,'w+');
        fprintf(fqsub,'source /usr/cenir/sge/default/common/settings.sh \n');
        
    else
        fqsub = fopen(qsubname,'a+');
    end
    
    fprintf(fqsub,'qsub -q %s -o %s -e %s %s\n',par.queu,jname_log,jname_err,jname);
    
    fclose(fqsub);
    
    unix(['chmod +x  ' qsubname]);
    
else
    cd(cwd)
end

