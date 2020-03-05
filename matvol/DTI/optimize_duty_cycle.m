function optimize_duty_cycle(B)


%B=reshape(cell2mat(Vector),3,65)
B=Binit;
clear Bnew

ind=1;

for k=1:size(B,2)

Bnew(:,k) = B(:,ind);
B(:,ind)=[];
    
Bdiff = abs(B-repmat(Bnew(:,k),[1  size(B,2)]));
Bdiffmax=max(Bdiff);

[v ind] = min(Bdiffmax);


end

%les diff max sur les axes
max(abs(diff(Bnew,1,2)))

max(abs(Bnew-repmat(Bnew(:,end),[1 size(Bnew,2)])))

bb= [ Bnew(:,1:6) Bnew(:,end) Bnew(:,7:end-1]
  max(abs(diff(bb,1,2)))  

  Bnew=bb
max(abs(Bnew-repmat(Bnew(:,end),[1 size(Bnew,2)])))
bb= [ Bnew(:,1:44) Bnew(:,end) Bnew(:,45:end-1)]

Bnew=bb

dd = [Bnew(:,end-1:end) Bnew(:,1:end-2)] 

ff=fopen('dir.txt','w+')

for k=1:size(dd,2)

fprintf(ff,'Vector[%d] = (%f ,%f , %f )\n',k-1,dd(1,k),dd(2,k),dd(3,k));
end
fclose(ff)
