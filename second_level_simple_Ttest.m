
%% PARAMS: DO CHANGE %%

controls_dir = '/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/Processed_566_471_vol/';
model = 'words';
%color
%      1      'object_wrong_color'                 
%      2      'object_grey_scale'                  
%      3      'mondirans_grey_scale'               
%      4      'mondrian_color'                     
%      5      'object_good_color'                  
%      6      'mondrian_color_vs_greyScale'        
%      7      'object_color_vs_greyScale' 
%      8      'object_wrong_color_vs_greyScale' 
%      9      'all_color_vs_greyscale'             
%     10      'all_greyscale_vs_color'             
%     11      'object_good_vs_bad_color'           
%     12      'object_bad_vs_good_color'           
%     13      'objectsCOLvsGS_vs_mondrianCOLvsGS'   
%     14      'all_color_vs_greyscale_inc_wrongCol'
%     15      'objects_vs_mondrians'
%     16      'color_x_shape_interaction'
%     17      'color_x_shape_interaction2'

%words
%     1{'numbers'                      }
%     2{'words'                        }
%     3{'faces'                        }
%     4{'houses'                       }
%     5{'tools'                        }
%     6{'body'                         }
%     7{'numbers_vs_others_noBODY'     }
%     8{'words_vs_others_noBODY'       }
%     9{'faces_vs_others_noBODY'       }
%     10{'houses_vs_others_noBODY'      }
%     11{'tools_vs_others_noBODY'       }
%     12{'words_vs_faces+houses+tools'  }
%     13{'numbers_vs_faces+houses+tools'}
%     14{'words_vs_numbers'             }
%     15{'numbers_vs_words'             }
%     16{'faces_vs_(houses+tools)'      }
%     17{'houses_vs_(faces+tools)'      }
%     18{'tools_vs_(faces+houses)'      }
% 19 tools vs faces
% 20 faces vs tools

contrast = [14];

%% FUNCTION: DO NOT CHANGE %%


for c = 1:length(contrast)

    spm_struct_for_t_image = spm_vol(fullfile('/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/Processed_566_471_vol/1001',...
        ['stats_' model], sprintf('spmT_%04d.nii',contrast(c))));
    conname = spm_struct_for_t_image.descrip(strfind(spm_struct_for_t_image.descrip, ': ')+2: end);
    
    final_dir = {fullfile('/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/second_level/20_pp', conname)};
    
    if ~exist(final_dir{:})
        mkdir(final_dir{:})
    end

    
    
    scans = dir([controls_dir '**/stats_' model sprintf('/spmT_%0.4d.nii', contrast(c))]);
    scans = fullfile({scans.folder}, strcat({scans.name}, ',1'))';

    matlabbatch{1}.spm.stats.factorial_design.dir = final_dir;
    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = scans;
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

    spm_jobman('run',matlabbatch)
    
end
