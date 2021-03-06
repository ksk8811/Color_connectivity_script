%http://www.emmanuelcaruyer.com/q-space-sampling.php
l=load('/tmp/s1.txt')

 ii=l(:,1)==1;b1 = l(ii,2:4);
 ii=l(:,1)==2;b2 = l(ii,2:4);
 ii=l(:,1)==3;b3 = l(ii,2:4);

f=fopen('Diff_micro.txt','w+')

numd=91

numdifftot = floor(numd/9*10)

fprintf(f,'#micro %d\n[directions=%d]\nCoordinateSystem = xyz\nNormalisation = none\n',numdifftot,numdifftot)

bv=b3'
kk=1
for k=1:numd
    fprintf(f,'Vector[%d] = ( %f, %f,%f)\n',kk-1,bv(1,k),bv(2,k),bv(3,k));
    kk=kk+1
    if mod(k,9)==0 && k<numd
        fprintf(f,'Vector[%d] = (0, 0, 0)\n',kk-1);
        kk = kk+1;
    end
end

fclose(f)


%pour nodii insert BP

f=fopen('Diffnodi64.txt','w+')
kk=1;
numdifftot = numd/8*9;
fprintf(f,'#noddi %d\n[directions=%d]\nCoordinateSystem = xyz\nNormalisation = none\n',numdifftot,numdifftot)

fprintf(f,'Vector[%d] = (0, 0, 0)\n',kk-1);
kk = kk+1;

for k=1:numd
    fprintf(f,'Vector[%d] = ( %f, %f,%f)\n',kk-1,bv(1,k),bv(2,k),bv(3,k));
    kk=kk+1
    if mod(k,8)==0 && k<numd
        fprintf(f,'Vector[%d] = (0, 0, 0)\n',kk-1);
        kk = kk+1;
    end
end
fclose(f)

