function vol = sort_hdr_into_volume(hdr)

%
% First of all, sort into volumes based on relevant
% fields in the header.
%

vol{1}{1} = hdr{1};
for i=2:length(hdr),
  %rrr
  if isfield(hdr{i},'ImageOrientationPatient')
  
    orient = reshape(hdr{i}.ImageOrientationPatient,[3 2]);
    xy1    = hdr{i}.ImagePositionPatient*orient;
    match  = 0;
    if isfield(hdr{i},'CSAImageHeaderInfo') && isfield(hdr{1}.CSAImageHeaderInfo,'name')
        ice1 = sscanf( ...
            strrep(get_numaris4_val(hdr{i}.CSAImageHeaderInfo,'ICE_Dims'), ...
            'X', '-1'), '%i_%i_%i_%i_%i_%i_%i_%i_%i')';
        dimsel = logical([1 1 1 1 1 1 0 0 1]);
    else
        ice1 = [];
    end;
    for j=1:length(vol),
        orient = reshape(vol{j}{1}.ImageOrientationPatient,[3 2]);
        xy2    = vol{j}{1}.ImagePositionPatient*orient;
        dist2  = sum((xy1-xy2).^2);

        % This line is a fudge because of some problematic data that Bogdan,
        % Cynthia and Stefan were trying to convert.  I hope it won't cause
        % problems for others -JA
        dist2 = 0;

        if strcmp(hdr{i}.Modality,'CT') && ...
                strcmp(vol{j}{1}.Modality,'CT') % Our CT seems to have shears in slice positions
            dist2 = 0;
        end;
        if ~isempty(ice1) && isfield(vol{j}{1},'CSAImageHeaderInfo') && isfield(vol{j}{1}.CSAImageHeaderInfo(1),'name')
            % Replace 'X' in ICE_Dims by '-1'
            ice2 = sscanf( ...
                strrep(get_numaris4_val(vol{j}{1}.CSAImageHeaderInfo,'ICE_Dims'), ...
                'X', '-1'), '%i_%i_%i_%i_%i_%i_%i_%i_%i')';
            if ~isempty(ice2)
                identical_ice_dims=all(ice1(dimsel)==ice2(dimsel));
            else
                identical_ice_dims = 0; % have ice1 but not ice2, ->
                % something must be different
            end,
        else
            identical_ice_dims = 1; % No way of knowing if there is no CSAImageHeaderInfo
        end;
        try
            match = hdr{i}.SeriesNumber            == vol{j}{1}.SeriesNumber &&...
                hdr{i}.Rows                        == vol{j}{1}.Rows &&...
                hdr{i}.Columns                     == vol{j}{1}.Columns &&...
                sum((hdr{i}.ImageOrientationPatient - vol{j}{1}.ImageOrientationPatient).^2)<1e-5 &&...
                sum((hdr{i}.PixelSpacing            - vol{j}{1}.PixelSpacing).^2)<1e-5 && ...
                identical_ice_dims && dist2<1e-3;
            %if (hdr{i}.AcquisitionNumber ~= hdr{i}.InstanceNumber) || ...
            %   (vol{j}{1}.AcquisitionNumber ~= vol{j}{1}.InstanceNumber)
            %    match = match && (hdr{i}.AcquisitionNumber == vol{j}{1}.AcquisitionNumber)
            %end;
            % For raw image data, tell apart real/complex or phase/magnitude
            if isfield(hdr{i},'ImageType') && isfield(vol{j}{1}, 'ImageType')
                match = match && strcmp(hdr{i}.ImageType, vol{j}{1}.ImageType);
            end;
            if isfield(hdr{i},'SequenceName') && isfield(vol{j}{1}, 'SequenceName')
                match = match && strcmp(hdr{i}.SequenceName,vol{j}{1}.SequenceName);
            end;
            if isfield(hdr{i},'SeriesInstanceUID') && isfield(vol{j}{1}, 'SeriesInstanceUID')
                match = match && strcmp(hdr{i}.SeriesInstanceUID,vol{j}{1}.SeriesInstanceUID);
            end;
            if isfield(hdr{i},'EchoNumbers')  && isfield(vol{j}{1}, 'EchoNumbers')
                match = match && hdr{i}.EchoNumbers == vol{j}{1}.EchoNumbers;
            end;
        catch
            match = 0;
        end
        if match
            vol{j}{end+1} = hdr{i};
            break;
        end;
    end;
    if ~match,
        vol{end+1}{1} = hdr{i};
    end;
  
  end;
end

%dcm = vol;
%save('dicom_headers.mat','dcm');

%
% Secondly, sort volumes into ascending/descending
% slices depending on .ImageOrientationPatient field.
%

vol2 = {};
for j=1:length(vol),
    orient = reshape(vol{j}{1}.ImageOrientationPatient,[3 2]);
    proj   = null(orient');
    if det([orient proj])<0, proj = -proj; end;

    z      = zeros(length(vol{j}),1);
    for i=1:length(vol{j}),
        z(i)  = vol{j}{i}.ImagePositionPatient*proj;
    end;
    [z,index] = sort(z);
    vol{j}    = vol{j}(index);
    if length(vol{j})>1,
        % dist      = diff(z);
        if any(diff(z)==0)
            tmp = sort_into_vols_again(vol{j});
            vol{j} = tmp{1};
            vol2 = {vol2{:} tmp{2:end}};
        end;
    end;
end;
vol = {vol{:} vol2{:}};
for j=1:length(vol),
    if length(vol{j})>1,
        orient = reshape(vol{j}{1}.ImageOrientationPatient,[3 2]);
        proj   = null(orient');
        if det([orient proj])<0, proj = -proj; end;
        z      = zeros(length(vol{j}),1);
        for i=1:length(vol{j}),
            z(i)  = vol{j}{i}.ImagePositionPatient*proj;
        end;
        [z,index] = sort(z);
        dist      = diff(z);
        if sum((dist-mean(dist)).^2)/length(dist)>1e-4,
            fprintf('***************************************************\n');
            fprintf('* VARIABLE SLICE SPACING                          *\n');
            fprintf('* This may be due to missing DICOM files.         *\n');
            if checkfields(vol{j}{1},'PatientID','SeriesNumber','AcquisitionNumber','InstanceNumber'),
                fprintf('*    %s / %d / %d / %d \n',...
                    deblank(vol{j}{1}.PatientID), vol{j}{1}.SeriesNumber, ...
                    vol{j}{1}.AcquisitionNumber, vol{j}{1}.InstanceNumber);
                fprintf('*                                                 *\n');
            end;
            fprintf('*  %20.4g                           *\n', dist);
            fprintf('***************************************************\n');
        end;
    end;
end;
return;
%_______________________________________________________________________



%_______________________________________________________________________
function val = get_numaris4_val(str,name)
name = deblank(name);
val  = {};
for i=1:length(str),
    if strcmp(deblank(str(i).name),name),
        for j=1:str(i).nitems,
            if  str(i).item(j).xx(1),
                val = {val{:} str(i).item(j).val};
            end;
        end;
        break;
    end;
end;
val = strvcat(val{:});
return;
%_______________________________________________________________________
