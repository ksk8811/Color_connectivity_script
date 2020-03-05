function do_batch5(param_file)
% Toplevel batch for preprocessings
%

if ~exist('param_file')
  param_file='';
end

do_preproc(param_file);
do_first_level(param_file);
