function bool = is_dicom_series_type(hdr,type)

bool = 0;

if iscell(hdr)
    hdr = hdr{1};
end


switch type
    case 'derived'

        bool = ~isempty(strfind(hdr.ImageType,'DERIVED')) ...
            || ~isempty(strfind(hdr.ImageType,'SECONDARY'));
        
    case 'dti'
        bool = ~isempty(strfind(hdr.SequenceName,'ep_b')) || ...
            ~isempty(strfind(hdr.SequenceName,'re_b')); %for the resolve
    case 'fmri'
        bool = ~isempty(strfind(hdr.SequenceName,'epfid2d'));
        
    case 't1mpr'
        bool = ~isempty(strfind(hdr.SequenceName,'tfl3d1'));
        
    case 'tfl'
        bool = ~isempty(strfind(hdr.SequenceName,'SiemensSeq_tfl'));
     
    case 'spectro'
        bool = ~isempty(strfind(hdr.CSAImageHeaderType,'SPEC NUM'));
        
end



