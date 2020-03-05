function surfwrite(vf,fname,convention)
% surfwrite(vf,fname,[convention='asc'])
%
% fname = filename of a ascii vtk file
%
% S.Jbabdi 09/10

if(nargin<3)
  convention='asc';
end

nvertices=size(vf.vertices,1);
nfaces=size(vf.faces,1);

fid=fopen(fname,'Wt');


if(strcmp(convention,'asc'))
  fprintf(fid,'#!ascii file\n%d\t%d\n',nvertices,nfaces);
  x=vf.vertices;
    if(isfield(vf,'FaceVertexCData'))
      x=[x vf.FaceVertexCData]';
    else
      x=[x zeros(size(x,1),1)]';
    end
    fprintf(fid,'%f\t%f\t%f\t%f\n',x);
    x=[vf.faces-1 zeros(size(vf.faces,1),1)]';
    fprintf(fid,'%d\t%d\t%d\t%d\n',x);
else
  fprintf(fid,'# vtk DataFile Version 3.0\nthis file was written using matlab\n');
  fprintf(fid,'ASCII\nDATASET POLYDATA\nPOINTS %d float\n',nvertices);
  x=vf.vertices';
  fprintf(fid,'%f\t%f\t%f\n',x);
  fprintf(fid,'POLYGONS %d %d \n',nfaces,nfaces*4);
  x=[3*ones(size(vf.faces,1),1) vf.faces-1]';
  fprintf(fid,'%d\t%d\t%d\t%d\n',x);
 
  if(isfield(vf,'FaceVertexCData'))
      fprintf(fid,'POINT_DATA %d\n',nvertices);
      fprintf(fid,'SCALARS Scalars float\nLOOKUP_TABLE default\n');
      x=vf.FaceVertexCData';
  else
      x=zeros(size(vf.vertices,1),1)';
  end
  fprintf(fid,'%f\n',x);
  fprintf(fid,'VECTORS Vectors float\n');
  x=zeros(size(vf.vertices,1),3)';
  fprintf(fid,'%f\t%f\t%f\n',x);
  
end

fclose(fid);


