function a_build_labelledsurface_hcp(pth,labels,annot)
if nargin<3, annot = 'aparc.a2009s'; end
if ~iscell(labels) || length(labels)~=2, error('Need labels lists (one for each hemisphere)'); end

subject = load(strcat(pth,'/list'));
hemi = {'L' 'R'}; h = {'lh' 'rh'};
S = length(subject);

for k=1:S    
    pth_free = strcat(pth,'/',num2str(subject(k)),'/MNINonLinear/Native/');
    for i=1:length(hemi)
        a = gifti(strcat(pth_free,num2str(subject(k)),'.',hemi{i},'.',annot,'.native.label.gii'));
        srf = gifti(strcat(pth_free,num2str(subject(k)),'.',hemi{i},'.white.native.surf.gii')); srf.faces(:,1:3) = srf.faces(:,1:3)-1;
        [~,~,colortable] = read_annotation(strcat(getenv('FREESURFER_HOME'),'/subjects/fsaverage/label/',h{i},'.',annot,'.annot'));

        nbfaces = size(srf.faces,1); nbvertices = length(srf.vertices); vertexlab = zeros(nbvertices,1);
        for j=1:nbvertices, 
            if ~isempty(find(colortable.table(:,5)==a.cdata(j))), vertexlab(j) = find(colortable.table(:,5)==a.cdata(j))-1; end, end
        disp([num2str(length(unique(vertexlab))) ' labels found'])

        vertexlabout = zeros(size(vertexlab));
        for j=1:length(labels{i})
           if isempty(find(vertexlab==labels{i}(j))), warning(['Label ' num2str(labels{i}(j)) ' not found in ' hemi{i} ' hemipshere']); end
           else vertexlabout(vertexlab==labels{i}(j)) = labels{i}(j);
        end

        fid = fopen(strcat(pth_free,'/',num2str(subject(k)),'.',hemi{i},'.white.labels.asc'),'w');
        fprintf(fid,'%s\n',strcat('#!ascii version of ',pth_free,'/',num2str(subject(k)),'.',hemi{i},'.white'));
        fprintf(fid,'%i %i\n',nbverticesout,nbfacesout);
        out = [srf.vertices vertexlabout]; for j=1:nbvertices, fprintf(fid,'%f %f %f %i\n',out(j,:)); end
        out = [srf.faces zeros(nbfaces,1)]; for j=1:nbfaces, fprintf(fid,'%i %i %i %i\n',out(j,:)); end
        fclose(fid);
    end
end

For instance, in order to save a surface file for label number LAB:
lab=gifti('label.gii');
surf=gifti('midthickness.surf.gii');

vf.faces=surf.faces;
vf.vertices=surf.vertices;
vf.FaceVertexCData = double(lab.cdata==LAB);
surfwrite(vf,'mysurf.asc');

