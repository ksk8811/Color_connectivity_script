function y = T1_exp(in,TI)

Ab=in(1);
T1 = in(2);

%y = Ab * (1-2*exp(-TI/T1)) ; %for TI inversion
y = Ab * (1-exp(-TI/T1)) ; %for multiple TR acquisition