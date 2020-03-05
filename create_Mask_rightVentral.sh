# extract temporal inf (89), +  occipital inf (53) + fusiform gyri (55) in AAL atlas
aal=/Applications/mricron/mricron.app/Contents/MacOS/templates/aal.nii.gz
#output_dir=/Users/k.siudakrzywicka/Desktop/RDS_fMRI/RDS_localizers/Mask

output_dir="/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/color_rs_connectivity/masks_for_figs/"

#fslmaths $aal -thr 46.5 -uthr 48.5 $output_dir/lingual
#fslmaths $aal -thr 38.9 -uthr 40.5 $output_dir/parahippocampal
#fslmaths $aal -thr 54.5 -uthr 56.5 $output_dir/fusiform
#fslmaths $aal -thr 88.5 -uthr 90.5 $output_dir/ITG
#fslmaths $aal -thr 52.5 -uthr 54.5 $output_dir/IOG

# fslmaths $aal -thr 42.5 -uthr 43.5 $output_dir/Calc_L
# fslmaths $aal -thr 44.5 -uthr 45.5 $output_dir/Cun_L
# fslmaths $aal -thr 46.5 -uthr 47.5 $output_dir/Lin_L
# fslmaths $aal -thr 48.5 -uthr 49.5 $output_dir/SOG_L
# fslmaths $aal -thr 50.5 -uthr 51.5 $output_dir/MOG_L
# fslmaths $aal -thr 52.5 -uthr 53.5 $output_dir/IOG_L
#
#
# fslmaths $aal -thr 82.5 -uthr 83.5 $output_dir/Sup_TL_L
# fslmaths $aal -thr 86.5 -uthr 87.5 $output_dir/Mid_TL_L
# #fslmaths $aal -thr 80.5 -uthr 81.5 $output_dir/Sup_TG_L
# fslmaths $aal -thr 84.5 -uthr 85.5 $output_dir/Mid_TG_L
# fslmaths $aal -thr 88.5 -uthr 89.5 $output_dir/Inf_TG_L
#
# fslmaths $aal -thr 40.5 -uthr 41.5 $output_dir/Hippocampus_L
# fslmaths $aal -thr 36.5 -uthr 37.5 $output_dir/Amygdala_L
# fslmaths $aal -thr 69.5 -uthr 71.5 $output_dir/Putamen_L

# merge them
cd $output_dir
# fslmaths bin_AF_left_vs_right_hippocampus.nii -mas Hippocampus_L.nii AF_left_vs_right_AALhippocampus.nii
fslmaths AF_left_vs_right_AALhippocampus.nii -bin bin_AF_left_vs_right_AALhippocampus.nii

fslmaths rbin_AF_left_vs_right_hippocampus_thr.nii -mas rAmygdala_L_thr.nii AF_left_vs_right_AALamygdala.nii
fslmaths AF_left_vs_right_AALamygdala.nii -bin bin_AF_left_vs_right_AALamygdala.nii

fslmaths rbin_AF_left_vs_right_hippocampus_thr.nii -mas rPutamen_L_thr.nii AF_left_vs_right_AALputamen.nii
fslmaths AF_left_vs_right_AALputamen.nii -bin bin_AF_left_vs_right_AALputamen.nii



# #fslmaths lingual -add parahippocampal -add fusiform -add ITG -add IOG -bin anat_all_gyri
# fslmaths Calc_L -add Cun_L -add Lin_L -add MOG_L -add SOG_L -add IOG_L -bin Occipital_L
# fslmaths Sup_TL_L -add Mid_TL_L -add Mid_TG_L -add Inf_TG_L -bin Temporal_L
# # include only y=-80 (include almost all LOC) to -30 (include almost all PPA)
# # note in FSL y => 126 +y
# #fslroi anat_all_gyri anat_all_gyri_chopped_bilateral 0 -1 46 50 0 -1
# fslroi Temporal_L Temporal_L_chopped 0 -1 106 -1 0 -1
# ## modify x coords to select one hemisphere
