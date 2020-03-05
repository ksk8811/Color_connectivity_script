function h=linear_and_derivative(i1,i2,mask)
%merci daniel !

s1=size(i1);
s2=size(i2);

s=size(i1);
s(3)=s(3)+size(i2,3)+1;
h=zeros(s);
% create matrix A
% [s1;s2;constraints]=A * HighRes +N


for x=1:s(1)
    
    for y=1:s(2)
        if exist('mask','var')
            if mask(x,y)<0.5
                continue
            end
        end
        cons=s1(3)+s2(3)+s1(3)-1+s2(3)-1;
        A= zeros(cons,s(3));
        B= zeros(cons,1);
        idx=0;
        % first terms for fidelity of the data
        for c=1:s1(3)
            idx=idx+1;
            A(idx,2*c-1)=0.5;
            A(idx,2*c  )=0.5;
            B(idx)       =i1(x,y,c);
        end
        for c=1:s2(3)
            idx=idx+1;
            A(idx,2*c  )=0.5;
            A(idx,2*c+1)=0.5;
            B(idx)       =i2(x,y,c);
        end
        % second terms for derivatives
        for c=1:(s1(3)-1)
            idx=idx+1;
            % we could weight the other term of the voxel but less
            % to take it into account but focusing the closest one
            A(idx,2*c-1)= 0.1;
            A(idx,2*c  )= 0.9;
            A(idx,2*c+1)=-0.9;
            A(idx,2*c+2)=-0.1;
            B(idx)       =i1(x,y,c )-i1(x,y,c+1);
        end
        for c=1:(s2(3)-1)
            idx=idx+1;
            % we could weight the other term of the voxel but less
            % to take it into account but focusing the closest one
            A(idx,2*c  )  = 0.1;
            A(idx,2*c+1)  = 0.9;
            A(idx,2*c+2)  =-0.9;
            A(idx,2*c+3)  =-0.1;
            B(idx)       =i2(x,y,c )-i2(x,y,c+1);
        end
        %h(x,y,:)=A\B;
        h(x,y,:)=lsqr(A,B);
    end
end