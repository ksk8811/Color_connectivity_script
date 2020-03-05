
res_dir ='/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/color_rs_connectivity/masks_for_figs/partial/';
cd(res_dir)
files = dir('*.nii');
files = {files.name};

curr_maps  = strcat(res_dir, files); % Cell array with threshholded .nii files.
order = [5 6 1 2 3 4];
curr_maps = curr_maps(order);

curr_maps = curr_maps(2:2:6); %left map

plots = struct();
plots.maps = {[1,2,3]};

colors = [153 255 102;... anterior left
    254 180 63;... anterior right
    255 102 255;... central left
    254 180 63; ... central right
    0 153 255;... occipital left
    58 135 253; ...occipital right
    ];

colors = colors(order,:);
colors = colors(1:2:6, :); %left colors

color_gradients = { ...
    colorGradient((colors(1,:)/1.5)./255, colors(1,:)/255, 128), ... 
    colorGradient((colors(2,:)/1.5)/255, colors(2,:)/255, 128), ... 
    colorGradient((colors(3,:)/1.5)/255, colors(3,:)/255, 128),... 
%     colorGradient((colors(5,:)/1.5)/255, colors(5,:)/255, 128),... 
%     colorGradient((colors(6,:)/1.5)/255, colors(6,:)/255, 128), ...
%     colorGradient((colors(7,:)/1.5)/255, colors(7,:)/255, 128), ...

    
    };


plots.gradients = {color_gradients};

% for res=plots.maps{plt}
%     curr_maps{end+1} = [plot_base_dirname plot_base(res).name '/final_map.nii'];
% end

global SAMI_conn_no_colorbar;
SAMI_conn_no_colorbar = false;


global SAMI_conn_colorgradiants;
SAMI_conn_colorgradiants = plots.gradients{1};

% Contrasta of sulci/gyri line 137
% Change multiplier of first X
%%cdat=cellfun(@(x)conn_bsxfun(@times,1-.05*x,shiftdim([.7,.65,.6],-1)),data.curv,'uni',0);%cdat=cellfun(@(x)conn_bsxfun(@times,.75-.04*x,shiftdim([1,.9,1],-1)),data.curv,'uni',0);

% global SAMI_conn_max_t_val;
% SAMI_conn_max_t_val = {};
% global SAMI_conn_min_t_val;
% SAMI_conn_min_t_val = {};
% 
% SAMI_conn_min_t_val = {0, 0, 0 ,0};
% SAMI_conn_max_t_val{1} = tinv(1-0.0001, 10); % p< 0.000001 - one sided T(1,10)
% SAMI_conn_max_t_val{2} = tinv(1-0.0001, 10); % p< 0.000001 - one sided T(1,10)
% SAMI_conn_max_t_val{3} = tinv(1-0.0001, 10); % p< 0.000001 - one sided T(1,10)
% SAMI_conn_max_t_val{4} = tinv(1-0.0001, 10); % p< 0.000001 - one sided T(1,10)

conn_mesh_display_multi(curr_maps,'');