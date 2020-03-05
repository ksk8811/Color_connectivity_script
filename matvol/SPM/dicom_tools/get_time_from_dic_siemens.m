function [h,m,s,ms] = get_time(t)

h = floor(t/3600);
mm = t/3600 -h;
m = floor(mm*60);
ss = mm*60-m;
s = floor(ss*60);
ms = floor((ss*60-s)*1000);


