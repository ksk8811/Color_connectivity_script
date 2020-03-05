function [hdr4D1 hdr_qt1] = util_compute_asl_subtract(aslfiles1,numSess,...
    fileOrder,CBFmodel,seqParams,M0file,doAddition,outputfilename,...
    maskfile,save3Dfiles,subtractionType,dataType,fROI,...
    dont_recompute_subtraction,rmv_start_imgs)

% Perform subtraction (addition) of pairs of ASL images to compute 
% flow (BOLD) contrast maps

% Mich�le Desjardins, January 2012

% Inputs :
%   aslfiles    : pathh&name of ASL volumes times series (1 file per line)
%   fileOrder   : order in which files were selected...
%                 case 1 % 'All control - then all tagged images'                    
%                 case 2 % 'All tagged - then all control images'
%                 case 3 % 'Control, tag, control, tag...'
%                 case 4 % 'Tag, control, tag, control...'}'
%   CBFmodel :   Model for calibrating absolute CBF
%               ('noCalibr','vanOsch','Wang','PASL')
%   seqParams : ASL sequence parameters - only used in flow
%                  calibration - fields depends on sequence type
%                   Not exhaustive : 
%                 'noCalibr' : no absolute flow computation.
%                 'PASL': 
%                   pasl.M0 : path&name of M0 image for flow calibration
%                   (can be empty)
%                   pasl.WMmask (white matter mask), pasl.TE, TI1, TI2
%                 'Wang':
%                   casl.useM0mean : boolean; use brain mean value for M0 
%                   (rather than individual voxel value) 
%                   casl.M0, casl.w, casl.tau (see details in function
%                   subfunc_calibrateCBF)
%   doAddition  : boolean; perform addition (rather than subtraction)
%   useM0mean   : 
%   outputfilename : filename for saving subtraction (addition) results (no
%                    path; file will be saved in aslfiles directory, in a
%                    subfolder.
%   maskfile    : path&name of file containing image for masking
%                 subtraction (addition). (can be empty - then a mask will
%                 be generated by thresholding the asl mean image)
%   save3Dfiles : boolean; save 3D output files in addition to 4D
%   subtractionType : ref. Aguirre 2002 NI 15:488-500.
%         case 0 'simple' (pairwise subtaction)
%         case 1 'surround' (average of 2 neighbouring images)
%         case 2 'sinc' (sinc interpolation of time series to the same instants)
%   dataType    : data type for output file...
%                   0 = 'SAME' (as aslfiles datatype)
%                   2 = 'UINT8   - unsigned char'
%                   4 = 'INT16   - signed short'
%                   8 = 'INT32   - signed int'
%                   16 = 'FLOAT32 - single prec. float'
%                   64 = 'FLOAT64 - double prec. float'
%   fROI        : path&name of file containing ROI mask; if a ROI is
%                 specified, the average value of CBF over this ROI will be
%                 displayed in the command window. The image should be in
%                 the same space as the ASL data.
%   

% Output :
%  1 of 2 time series images and 2 mean images will be saved :
%   - The perfusion time series(subtraction result)
%   in a.u. and its mean (same size and length as EPI).
%   The calibrated (in mL/100g/min units) mean
%   image and time series are also saved.
% OR
%   - The BOLD time series(addition result)
%   in a.u. and its mean (same size and length as EPI)
% In addition a mask image will be saved.

% Outputs (for dependcies)
hdr4D1 = {}; % header(s) of 4D volume(s), result of subtraction (flow) or addition (bold) for each session
hdr_qt1 = {}; % header(s) of 4D volume(s), calibrated flow (empty in case of bold) for each session

% Add (flow) or subtract (BOLD)
if ~doAddition % flow
    prefixForOutputFile = 'flow';
elseif doAddition % BOLD
    prefixForOutputFile = 'bold';
else % By default
    doAddition = 0;
    prefixForOutputFile = 'flow';
end

% Images to ignore
if exist('rmv_start_imgs') && rmv_start_imgs>0
    aslfiles1 = aslfiles1(1+rmv_start_imgs:end,:);
end

% Size of functional images
hdr_EPI = spm_vol(aslfiles1(1,:));
sizeEPI = hdr_EPI.dim;
[~, ~, extEPI] = fileparts(hdr_EPI.fname);
extEPI = extEPI(1:4);

% Length of time series (number of control/label pairs)
nTimePts = size(aslfiles1,1)./numSess;
%nCtrlTagPairs = nTimePts/2;%size(f{subj}.fEPI{1},1);

% Loop over sessions (separate treatment for each session)
for iSess = 1:numSess
    aslfiles = aslfiles1( (1+nTimePts*(iSess-1)) : (nTimePts*iSess) , : ) ;
    
    
    % Create subdirectory for output images
    [dirEPI] = fileparts(aslfiles(1,:));
    currentDir = pwd;
    cd(dirEPI);
    newDirName = [dirEPI filesep prefixForOutputFile];
    if ~exist(newDirName), mkdir(newDirName), end;
    cd(newDirName)

    % Read data
    hdrs = spm_vol(aslfiles);
    data = spm_read_vols(hdrs);

    % Brain mask
    %   Explicit mask (optional user input)
    if ~isempty(maskfile)
        hdr_mask = spm_vol(maskfile);
        mask = spm_read_vols(hdr_mask);
    else
        mask = [];
    end
    %   or Create mask by thresholding functional image
    if max(size(size(mask)))~=3 || any(size(mask)~=sizeEPI)
        keyboard
        mean_data = mean(data,4);
        threshold = 0.1;
        mask = mean_data > threshold*max(mean_data(:));
    end



    % Order of images (tag, control...)
    idx_ctrl = [];
    idx_tag = [];
    % Reorder data so that order of the volumes corresponds to the
    % order of the time series
    switch fileOrder
        case 1 % 'All control - then all tagged images'                    
            idx_ctrl = 1:(nTimePts/2);
            idx_tag = (nTimePts/2)+1:nTimePts;
            idx_reordered = [idx_ctrl(:) idx_tag(:)]';
            idx_reordered = idx_reordered(:);
        case 2 % 'All tagged - then all control images'
            idx_tag = 1:(nTimePts/2);
            idx_ctrl = (nTimePts/2)+1:nTimePts; 
            idx_reordered = [idx_tag(:) idx_ctrl(:)]';
            idx_reordered = idx_reordered(:);
        case 3 % 'Control, tag, control, tag...'
            idx_ctrl = 1:2:nTimePts;
            idx_tag = 2:2:nTimePts;
            idx_reordered = 1:nTimePts;
            idx_reordered = idx_reordered(:);
        case 4 % 'Tag, control, tag, control...'}'
            idx_ctrl = 2:2:nTimePts;
            idx_tag = 1:2:nTimePts;
            idx_reordered = 1:nTimePts;
            idx_reordered = idx_reordered(:);
        otherwise
    end

    tmp_name4D = fullfile(newDirName,outputfilename);
    [tmp_dir1 tmp_name1 tmp_ext1] = fileparts(tmp_name4D);
    tmp_namemean = fullfile(tmp_dir1,['mean_' tmp_name1 tmp_ext1]);

    % LOOP over time series
    if ~(dont_recompute_subtraction && spm_existfile(tmp_name4D) && ...
            spm_existfile(tmp_namemean))
        % Compute subtraction
        switch subtractionType
        % To obtain a final TR equal to sequence TR, we use a
        % moving time window to subtract each label-control and
        % control-label pair
        % (rather than a doubled TR after subtraction)  

            case 0
                % SIMPLE
                % for i = 1:end-1
                %   flow(i) = (-1)^i * ( control/tag(i) - tag/control(i) )
                %   (could be (-1)^(i+1) depending on tag/control order)
                % end
                % and for the boundary points:
                % flow(end) = data(end) - data(end-1);

                data_reordered = data(:,:,:,idx_reordered);

                % Perform subtraction
                for t_idx = 1:nTimePts-1;

                    img_i = data_reordered(:,:,:,t_idx);
                    img_ip1 = data_reordered(:,:,:,t_idx+1);

                    % Flow : control - tag (moving spins have negative signal)
                    if doAddition
                        img_f_i = (img_ip1/2 + img_i/2) .* mask;
                    else
                        img_f_i = (-1)^(t_idx+1 - mod(fileOrder,2)) .* (img_i - img_ip1) .* mask;
                        % case 1,3 (mod=1): ctrl image first; 2-1=tag-control
                        % case 2,4 (mod=2): tag image first
                    end


                    % Output : create the nifti object, assign the filename and correct
                    % coregistration info ("mat" transformation matrix)
                    % 4D output file            
                    hdr4D = hdrs(idx_reordered(t_idx));
                    hdr4D.fname = fullfile(newDirName,outputfilename);
                    hdr4D.dim = hdrs(idx_reordered(t_idx)).dim;
                    if dataType==0 % same as input files
                        hdr4D.dt = hdrs(idx_reordered(t_idx)).dt;
                    else
                        hdr4D.dt = [dataType 0]; % data Type
                    end            
                    hdr4D.pinfo = hdrs(idx_reordered(t_idx)).pinfo;
                    hdr4D.mat = hdrs(idx_reordered(t_idx)).mat;
                    hdr4D.n = [t_idx 1];
                    hdr4D.descrip = [hdrs(idx_reordered(t_idx)).descrip ' - ' prefixForOutputFile];
                    hdr4D.private = hdrs(idx_reordered(t_idx)).private;
                    hdr4D.private.dat.fname = hdr4D.fname;

                    dd = squeeze(img_f_i);
                    spm_write_vol(hdr4D,dd);

                    v4D(:,:,:,t_idx) = dd;

                    % 3D output files (optional)
                    if save3Dfiles
                        hdr3D = hdr4D;
                        [dir1 name1 ext1] = fileparts(hdr4D.fname);
                        hdr3D.fname = fullfile(dir1,...
                            [name1 sprintf('_%03.0f',t_idx) ext1]);
                        hdr4D.private.dat.fname = hdr4D.fname;
                        hdr4D.n = [1 1];
                        spm_write_vol(hdr3D,dd);
                    end


                end


                %end

                % TO IMPLEMENT
            case 1
                % SURROUND
                % for i = 2:end-1
                %   flow(i) = (-1)^i * ( data(i+1)/2 + data(i-1)/2 - data(i) )
                %   (could be (-1)^(i+1) depending on tag/control order)
                % end
                % and for the boundary points:
                % flow(1) = data(2) - data(1);
                % flow(end) = data(end) - data(end-1);

        %             % ------COPY SIMPLE SUB. BUT CHANGE THIS:
        %             % Control 2 (tag)
        %             hdr_im1 = spm_vol(f{1}.fEPI{1}(t_idx-1));
        %             img_im1 = spm_read_vols(hdr_ip1);
        %             if doAddition
        %                 img_f_i = (img_im1/4 + img_ip1/4 + img_i/2) .* brainMask;
        %             else
        %                 img_f_i = (-1)^t_idx .* (img_im1/2 + img_ip1/2 - img_i) .* brainMask;
        %             end

            case 2
                % SINC

            otherwise

        end


        % Compute mean bold/flow image and save it
        img_mean = mean(v4D,4);
        img_mean(isnan(img_mean)) = 0;
        hdr_mean = hdrs(1);
        hdr_mean.dt = hdr4D.dt;
        [dir1 name1 ext1] = fileparts(hdr4D.fname);
        hdr_mean.fname = fullfile(dir1,...
            ['mean_' name1 ext1]);
        hdr_mean.private.dat.fname = hdr_mean.fname;
        hdr_mean.n = [1 1];
        spm_write_vol(hdr_mean,img_mean);

    else

        hdr4Dall = spm_vol(tmp_name4D);
        hdr4D = hdr4Dall(end);
        tmp_hmean = spm_vol(tmp_namemean);
        v4D = spm_read_vols(hdr4D);
        img_mean = spm_read_vols(tmp_hmean);

    end
    clear tmp*

    % Compute calibration for mean flow image and save it
    if strcmp(prefixForOutputFile,'flow') && ~sum(strcmp(CBFmodel,'noCalibr'))

        % Load M0 image (fully relaxed magnetization)
        img_M0 = ones(size(img_mean));
        if ~isempty(M0file)
            hdr_M0 = spm_vol(M0file);
            % Check size (... and orientation? -> to implement!)
            img_M0 = spm_read_vols(hdr_M0);
        end
        % Alternatively, approximate it with the mean control image 
        if isempty(M0file) || max(size(size(img_M0))~=3) || size(img_M0)~=sizeEPI
            img_M0 = mean(data(:,:,:,idx_ctrl),4);
        end

        % Load (otional) ROI image for computing ROI average CBF
        img_ROI = ones(size(img_mean));
        if ~isempty(fROI)
            hdr_ROI = spm_vol(fROI);
            % Check size (... and orientation? -> to implement!)
            img_ROI = spm_read_vols(hdr_ROI);
            % 0/1 mask
            img_ROI(img_ROI>0.5) = 1;
            img_ROI(img_ROI<1) = 0;
        end
        % Can be omitted (we will then compute brain average)
        if isempty(fROI) || max(size(size(img_ROI))~=3) || size(img_ROI)~=sizeEPI
            img_ROI = mask;
        end

        % % Load minimum contrast image
        % % - not using minimum contrast image for calibration yet... to implement

        % M0
        switch lower(CBFmodel)
            case 'pasl' % M0 value in white matter
                useM0mean = 0;
                hdr_WM = spm_vol(seqParams.WMmask{1});
                img_WM = spm_read_vols(hdr_WM);
                try
                    img_WM(img_WM>0) = 1;
                    img_WM(img_WM<0) = 0;
                    img_M0 = img_M0 .* img_WM;
                    img_M0 = mean(img_M0(img_M0>0));
                catch
                    img_M0 = img_M0 .* mask;
                    img_M0 = mean(img_M0(img_M0>0));
                end

            case 'wang' % M0 mask or mean value
                useM0mean = seqParams.useM0mean;

            case 'vanosch'
                useM0mean = 0;
                hdr_CSF = spm_vol(seqParams.CSFmask{1});
                img_CSF = spm_read_vols(hdr_CSF);
                try
                    img_CSF(img_CSF>0) = 1;
                    img_CSF(img_CSF<0) = 0;
                    img_M0 = img_M0 .* img_CSF;
                    img_M0 = mean(img_M0(img_M0>0));
                catch
                    img_M0 = img_M0 .* mask;
                    img_M0 = mean(img_M0(img_M0>0));
                end

            otherwise
                %
        end

        % Compute calibrated image and save it
        [img_CBF img_CBFpositive] =...
            subfunc_calibrateCBF(0,img_mean,CBFmodel,seqParams,img_M0,...
            useM0mean,mask,[],img_ROI);

        hdr_qt = hdrs(1);
        hdr_qt.dt = hdr4D.dt;
        [dir1 name1 ext1] = fileparts(hdr4D.fname);
        hdr_qt.fname = fullfile(dir1,...
            ['mean_mLper100gperMin_' name1 ext1]);
        hdr_mean.private.dat.fname = hdr_qt.fname;
        hdr_qt.n = [1 1];
        spm_write_vol(hdr_qt,img_CBF);

    else
        hdr_qt = {};
    end

   hdr4D1 = [hdr4D1; hdr4D];
   hdr_qt1 = [hdr_qt1; hdr_qt];
   
end


end


function [CBF CBFgt0] = subfunc_calibrateCBF(flog,deltaM,CBFmodel,seqParam,...
    M0,useM0mean,brainMask,minContrast,ROImask)
% Compute quantitative CBF in mL/100g/min using perfusion measurement from
% CASL or pCASL

% Inputs :
%   flog : log file identifier (fid) for writing messages. 0 for screen
%          display only.
%   deltaM : measured flow signal (subtraction result)
%   M0 : measured fully relaxed magnetization (same size as deltaM or scalar)
%   useM0mean : Boolean specifying whether to use ROI-mean (1) or
%               individual-voxel (0) value for M0
%   brainMask : brain mask (1=brain/0=other) (same size as deltaM)
%   GMmask : gray matter mask (1=brain/0=other) (same size as deltaM)
%   minContrast : "minimum contrast" scan to approximate the sensitivity
%                 profile of the coil (same size as deltaM)
%   ROImask: optionnaly, if a 0/1 mask of a ROI is given, the average CBF
%            over this ROI will be displayed in the command window.

% Output :
%   CBF in mL/100g/min (same size as deltaM)


try minContrast;
    if size(minContrast) ~= size(deltaM)
        minContrast = ones(size(deltaM));
        write_log(flog,'calibrateCBF: Minimum contrast image must be same size as flow image. Ignoring (set to ones).');
    end
catch
    minContrast = ones(size(deltaM));
end

try brainMask;
    if size(brainMask) ~= size(deltaM)
        brainMask = ones(size(deltaM));
        write_log(flog,'calibrateCBF: Brain mask image must be same size as flow image. Ignoring (set to ones).');
    end
catch
    brainMask = ones(size(deltaM));
end

try M0;
    if (length(M0(:)) > 1) && sum((size(M0) ~= size(deltaM)))
        M0 = mean(M0(:));
        write_log(flog,'calibrateCBF: M0 must be same size as flow image or scalar. Using mean(M0(:)).');
    end
catch
    M0 = 1;
    write_log(flog,'calibrateCBF: M0 must be given in input. Calibration will be incomplete.');
end

try ROImask;
    displayMean = 1;
catch
    ROImask = brainMask;
    displayMean = 0;
end


% ASL sequence type
switch lower(CBFmodel)
    
    case 'pasl'
        
        % Constantes issues de la litt�rature %
        % ----------------------------------- %
        % (tous les temps sont en ms) 
        waterPartCoeff = 1/1.06;% 1/ratio of proton density (=water) in blood (sagittal sinus) to WM
        % water partition coefficient in mL/g (0.9 in Herscovitch JCBFM 5:65-69 (1985))
        alpha = 0.95; % labelling efficiency (for pASL ~0.95)

        T1b = 1627; % T1 du sang � 3T (Lu MRM 2004 52:679�682) (1932 selon Stanisz MRM 54:507-512 (2005))
        T2b = 55; % T2* du sang � 3T (Wansapura J MRI 9:531�538 1999) (T2 = 275 selon Stanisz)
        T2wm = 47; % T2* de la mati�re blanche � 3T (Zhao MRM 58:592�596 2007) (T2 = 70 selon Stanisz)

        % Param�tres de la s�quence %
        % ------------------------- %
%         % (tous les temps sont en ms)
%         TE = 12;
%         TI1 = 700; % V�RIFIER
%         TI2 = 1400; % V�RIFIER
        TE = seqParam.TE;
        TI1 = seqParam.TI1;
        TI2 = seqParam.TI2;
        
        % Check for time units
        if TE < 0.1; TE = TE*1000; end
            % probably in s rather than ms
        if TI1 < 10; TI1 = TI1*1000; end
        if TI2 < 10; TI2 = TI2*1000; end             

        % Unit�s %
        % ------ %
        % (facteur � inclure si on d�sire obtenir CBF(0) en ml/min/100g)
        units = 1/6e6; % (mL/min/100g) / (mL/ms/g) 

        % Calibration du M0 du sang % 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Wong et al. MRM 39:702-708 (1998)
        M0b = M0 ./ waterPartCoeff .* exp( TE .* (1/T2wm - 1/T2b) );

        % Calcul du CBF0 %
        %%%%%%%%%%%%%%%%%%
        % Buxton et al. MRM 40:383-396 (1998) et Wong et al. MRM 39:702-708 (1998)
        CBF = deltaM ./ ( units .* 2 .* alpha .* TI1 .* exp(-TI2/T1b) .* M0 );
        
        
        
    case {'wang','pcasl'}
        % Reference: 
        %   Wang 2003, MRM 50:600-. Eq. 1.
        % Based on : 
        %   Wang 2002 MRM 48:242-54. Appendix. 
        %   Alsop 1996 JCBFM 16:1236-49. Appendix.
        % Equivalent to :
        %   Buxton 1998 MRM 40:383-96.

        % f = deltaM * 60 * 100 * lambda * R1art * exp(w*R1art) / (2 * alpha * M0 * (1-exp(-tau*R1art) )
        % mL/100g/min = a.u. * s/min * g/(100g) * mL/g * s^-1

        % where deltaM = ASL flow signal (subtraction result),
        %       lambda = tissue/blood water partition coefficient,
        %                ( (mLH2O/g brain)  /  (mLH2O/mL blood) )
        %       R1art  = longitudinal relaxation rate of arterial blood,
        %       alpha  = tagging efficiency,
        %       M0     = fully relaxed magnetization of brain, 
        %       w      = post-labeling delay,
        %       tau    = duration of the labeling pulse,  
        % The parameters of the dual-echo pCASL sequence used at UNF in summer-fall
        % 2010 (and up to today) (JJ Wang's sequence) are:
        %       w      = 0.9 s
        %       tau    = 2 s
        % At 3T we assume the following values for the other parameters:
        %       lambda = 0.9 mL/g (Herscovitch 1985 JCBFM 5:65-9)
        %       alpha  = 0.68     (Wu 2007 MRM 58:1020-27; for pCASL)
        %       T1art  = 1.700 s  (mean value from Stanisz 2005 54:507�12 and
        %                          Lu 2005 MRM 53:808�16)

        lambda = 0.9;    % mL/g
        alpha = 0.68;    % no units
        T1art = 1.700;   % s
        R1art = 1/T1art; % s^-1
        %tau = 1.500;     % s
        %w = 0.900;       % s
        tau = seqParam.tagDur;
        w = seqParam.postTagDelay;
        
%         % Check for time units
%         if tau > 10; tau = tau/1000; end
%             % probably in ms rather than s
%         if w > 10; w = w/1000; end       

        calibrFactor = 60 * 100 * lambda * R1art ...
            ./ (2 * alpha * (1-exp(-tau*R1art)) );
        decaySlice = exp(w*R1art);
        % IMPLEMENT w -> w+slice_time(zSlice-1)

        if useM0mean
            M0 = M0 .* ROImask;
            M0 = mean(M0(M0>0));
        end

        CBF = deltaM ./ M0 .* calibrFactor .* decaySlice .* brainMask .* minContrast;

        % % Different values for calibration parameters : 
        % 
        % % Rick Hoge's (from personal discussions, 2011):
        % lambda = 0.9;    % mL/g
        % alpha = 0.68;    % no units
        % T1art = 1.490;   % s
        % R1art = 1/T1art; % s^-1
        % tau = 2.000;     % s
        % w = 0.900;       % s
        % 
        % % Wang 2003 :
        % lambda = 0.9;    % mL/g
        % alpha = 0.71;    % no units
        % R1art = 0.83; % s^-1
        % tau = 2.000;     % s
        % w = 0.900;       % s
        % 
        % calibrFactor2 = 60 * 100 * lambda * R1art * exp(w*R1art) ...
        %     ./ (2 * alpha * (1-exp(-tau*R1art)) );
        % rapport = calibrFactor2/calibrFactor;
        % CBF = CBF*rapport;
        
    case 'vanosch'
        % van Osch et al. 2009, MRM 62:165-173
        
        % Used in Lille for pCASL sequence (Philips 3T)
        % TI = 1650 ms, labelling duration 1200 ms
        
        lambda = 0.76; % water content of blood
        alpha = 0.85; % tagging efficiency
        T1art = 1.680; % T1 of arterial blood (s)
        T2art = 50; % T2* of arterial blood (ms)
        w = seqParam.postTagDelay; % in s
        tau = seqParam.tagDur; % in s
        TR = seqParam.TR; % in s
        TE = seqParam.TE; % in ms
        % Check for time units
        if TE < 0.1; TE = TE*1000; end
        % probably in s rather than ms
        if TR > 50; TR = TR/1000; end
        % probably in ms rather than s
        
        nSlices = size(deltaM,3);
        
        calibrFactor = 6000 / 2 / lambda / alpha / T1art;
        M0CSF = M0/exp(TE/T2art);

        %decaySlice = exp(w/T1art); 
        %CBF = deltaM ./ M0CSF .* calibrFactor .* decaySlice .* brainMask .* minContrast;
        
        % Correct for slice acquisition time
        % Not really... Assume 1 slice acquisiton time = TE (approximation)
        %sliceAcqTime = TE/1000*1.75;
        % Assuming no delay in TR (min. TR / max. number of slices were used)
        sliceAcqTime = (TR-w-tau)/nSlices;    % TR - labelling time - post-labelling delay
        for iz = 1:nSlices
          switch seqParam.acqOrder
              case 1 % Ascending
                  decaySlice(iz) = exp( (w + (iz-1)*sliceAcqTime ) /T1art);
              case 2 % Descending
                  decaySlice(iz) = exp( (w + (nSlices-(iz-1))*sliceAcqTime ) /T1art);
              case 3 % Interleaved
                  decaySlice = exp(w/T1art); 
                  % To implement
              otherwise
                  decaySlice = exp(w/T1art); 
          end
          
          CBF(:,:,iz) = deltaM(:,:,iz) ./ M0CSF .* calibrFactor .*...
              decaySlice(iz) .* brainMask(:,:,iz) .* minContrast(:,:,iz);

        end
        
    otherwise
        
end


CBFgt0 = CBF;
CBFgt0(CBF<0) = 0;
        
if (size(ROImask)==size(CBF))
    if displayMean
        ROIcbf = ROImask.*CBF;%ROImask(~isnan(CBF)).*CBF(~isnan(CBF));
        ROIcbf = ROIcbf(ROImask~=0);
        fprintf('ROI-average CBF: %3.2f \n',mean(ROIcbf(:)));
    end
end


end

function write_log(flog,mlog)
    % Write to screen and to log file
    disp(mlog);
    try
        if flog
            for i=1:size(mlog,1);
                fprintf(flog,'%s\n',mlog(i,:));
            end
        end
    end
end




            

