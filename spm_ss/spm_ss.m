function spm_ss(varargin)
% SPM_SS Subject-specific analysis GUI
%

spm_ss_ver='10.a';

if nargin>1, 
    %disp(varargin); 
    if ischar(varargin{1}),
    elseif ishandle(varargin{1})
        switch(varargin{3}),
            case 'cv',
                spm_ss_crossvalidate_sessions;
            case 'lm',
                spm_ss_createlocalizermask;
            case 'surface',
                spm_ss_display;
            case 'preparePSTH',
                spm_ss_preparePSTH;
            case 'design',
                spm_ss_design;
            case 'estimate',
                spm_ss_estimate;
            case 'results',
                [ss,Ic]=spm_ss_selectcontrast;
                ss=spm_ss_contrast(ss,Ic,0);
                spm_ss_results(ss,Ic);
        end
    end
else
    h=findobj('tag',mfilename);
    if isempty(h),
        data.handles.fig=figure('units','norm','position',[.2,.5,.22,.2],'color','w','tag',mfilename,'menubar','none','numbertitle','off','name',[mfilename,' ',spm_ss_ver]);
        uicontrol('units','norm','position',[0,.8,1,.2],'style','frame','backgroundcolor','k');
        data.handles.uimenu=uimenu(data.handles.fig,'label','tools');
        data.handles.uimenu1=uimenu(data.handles.uimenu,'label','Creates Cross-validated contrasts','callback',{@spm_ss,'cv'});
        data.handles.uimenu2=uimenu(data.handles.uimenu,'label','Creates Localizer masks','callback',{@spm_ss,'lm'});
        data.handles.uimenu3=uimenu(data.handles.uimenu,'label','Renders subject-specific activations on brain surface','callback',{@spm_ss,'surface'});
        data.handles.uimenu4=uimenu(data.handles.uimenu,'label','Prepares PSTH analyses','callback',{@spm_ss,'preparePSTH'});
        data.handles.txt=uicontrol('units','norm','position',[.1,.85,.8,.1],'style','text','string','Subject-specific analyses','backgroundcolor','k','foregroundcolor','w','fontweight','bold','horizontalalignment','center');
        data.handles.button_design=uicontrol('units','norm','position',[.1,.525,.8,.2],'style','pushbutton','string','Specify 2nd-level','callback',{@spm_ss,'design'},'tooltipstring','GLM setup for subject-specific analyses');
        data.handles.button_estimate=uicontrol('units','norm','position',[.1,.325,.8,.2],'style','pushbutton','string','Estimate','callback',{@spm_ss,'estimate'},'tooltipstring','estimates parameters of a specified model');
        data.handles.button_results=uicontrol('units','norm','position',[.1,.075,.8,.2],'style','pushbutton','string','Results','callback',{@spm_ss,'results'},'tooltipstring','inference and regional responses etc.');
        set(data.handles.fig,'userdata',data);
    else
        data=get(h,'userdata');
    end
end


