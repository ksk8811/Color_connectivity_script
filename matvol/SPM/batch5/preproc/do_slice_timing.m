function jobs = do_slice_timing(ff,parameters,logfile,jobs)

nbjobs = length(jobs) + 1;

TR = parameters.TR;

%Test if file exist and not redoo

doit=0;


%check if exist an redo
off=addprefixtofilenames(ff,'a');

if ~isfield(parameters,'redo') 
  parameters.redo=1;
end

doit=1;

if ~parameters.redo
  doit=0;
  for kk=1:length(off)
    for kkk=1:size(off{kk},1)
      if ~exist(off{kk}(kkk,:))
	doit=1;break
      end
    end
    if (doit), break; end
  end

end


if ~doit
  logmsg(logfile,sprintf('Skipping slice Timing because all "a" files exist'));
  
else

  logmsg(logfile,sprintf('Slice timing on %d files starting with "%s"...',sum(cellfun('size',ff,1)),ff{1}(1,:)));

  for n=1:length(ff)
    jobs{nbjobs}.temporal{1}.st.scans{n} = cellstr(ff{n});
  end

  V = spm_vol(ff{1}(1,:));
  nbslices = V.dim(3);
  TA = TR - (TR/nbslices);

  
  [slice_order,ref_slice] = get_slice_order(parameters,nbslices);


  jobs{nbjobs}.temporal{1}.st.nslices = nbslices;
  jobs{nbjobs}.temporal{1}.st.tr = TR;
  jobs{nbjobs}.temporal{1}.st.ta = TA;
    
  jobs{nbjobs}.temporal{1}.st.so = slice_order;
  jobs{nbjobs}.temporal{1}.st.refslice = ref_slice;

end

end
