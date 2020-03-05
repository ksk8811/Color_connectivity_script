%
function tri_dicom_oct

% on selectionne le repertoire à trier
% contenant des fichiers DICOM (extension .IMA) de differentes series d'un
% meme sujet, exportees depuis l'IRM Siemens 3T Tri Tim 102/32.
%
% cree un repertoire par nom de sequence (champ SeriesDescription de
% l'en-tete DICOM) et y *copie* tous les fichiers .IMA correspondant a cette
% sequence. Attention : les fichiers ne sont pas deplaces, verifier a la
% main !
%
% seuls les fichiers de la modalite 'MR' sont tries.
%
% creation M Pelegrini-Issac 10/10/06
% dernieres modifs 12/10/06

% selection de la liste des repertoires contenant les fichiers DICOM

path(':/home/romain/dvpt/spm_dicom');

%DirList = input('Select a dir\n')%spm_get(-Inf,'*','Select Directories of DICOM files');

DirList ='/home/romain/data/spectro/ttt';

% boucle sur la liste des repertoires
for idir = 1:size(DirList,1)

    
    SeriesDescription = [];
    clear SeriesNumber ;

    % liste des fichiers DICOM du repertoire
    Dir = DirList(idir,:);
    D = deblank(Dir);
    DD = dir(D);

%    h = waitbar(0,'Getting information from DICOM files...');
    j = 1;
    for i=3:size(DD,2)
        [pathstr,filename,ext] = fileparts(DD(i).name);
        if ~DD(i).isdir & ext == '.IMA'
            hdr{j} = spm_dicom_headers(fullfile(D,DD(i).name));
            if hdr{j}{1}.Modality == 'MR'
                SeriesDescription = [SeriesDescription;hdr{j}{1}.SeriesDescription];        

    hdr{j}{1}.SeriesNumber
    whos (hdr{j}{1}.SeriesNumber)
    
                if ~exist('SeriesNumber')
		  SeriesNumber = str2num(hdr{j}{1}.SeriesNumber);
		else
		  SeriesNumber = [SeriesNumber;str2num(hdr{j}{1}.SeriesNumber)];
		end
                j=j+1;
	      else
		disp ( strcat('file ',DD(i).name ,' is not modality MR'))
            end
        end
%        waitbar(i/size(DD,1),h);
    end
%    close(h);

    % recupere les numeros de serie
    [B,I] = unique(SeriesNumber);

    textname = fullfile(D,'readme.txt');
    fid = fopen(textname,'wt');

    fprintf(fid,'%s\n',char(D));
    fprintf('%s\n',char(D));
    for k = 1:size(I,1)
        % ecrit dans le repertoire D un fichier texte readme.txt avec tous les 'numserie nomserie'
        fprintf(fid,'%d\t%s\n',SeriesNumber(I(k)),char(SeriesDescription(I(k))));
        fprintf('%d\t%s\n',SeriesNumber(I(k)),char(SeriesDescription(I(k))));
        % fabrique le nom du repertoire
        dirname = ['ser' num2str(SeriesNumber(I(k))) '_' char(SeriesDescription(I(k)))];
        % nettoie les caracteres speciaux
        dirname = nettoie_dir(dirname);
        % cree des repertoires 'serNUMSERIE_DESCRIPTION'
        [s,mess] = mkdir(fullfile(D,dirname));
        if s == 0
            error(mess);
        end
    end
    fprintf(fid,'%s\n');    
    fprintf('%s\n');
    fclose(fid);

    % retrie tous les fichiers pour les ranger dans le bon repertoire
%    h = waitbar(0,'Copying DICOM files...');
    for i=1:size(hdr,2)
            if hdr{i}{1}.Modality == 'MR'
                % nom du repertoire dans lequel ranger le fichier
                dirname = ['ser' num2str(hdr{i}{1}.SeriesNumber) '_' hdr{i}{1}.SeriesDescription];
                % nettoie les caracteres speciaux
                dirname = nettoie_dir(dirname);
                % copie le fichier dans le repertoire approprie
                [s,mess] = copyfile(hdr{i}{1}.Filename,fullfile(D,dirname));
                if s == 0
                   error(mess);
                end
            end
            waitbar(i/size(hdr,2),h);
    end
    close(h);
    
% fin de la boucle sur la liste des repertoires
end

% =========================================================================
% 
function dirname = nettoie_dir(dirname)

% cherche s'il y a des caracteres non alphanumeriques dans la chaine
str = isstrprop(dirname,'alphanum');
spec = find(~str);
% remplace les caracteres non alphanumeriques par des '_'
dirname(spec) = '_';
% pour fignoler, on supprime un '_' s'il y en a 2 qui se suivent
while ~isempty(strfind(dirname,'__'));
    dirname = strrep(dirname,'__','_');
end
% toujours pour fignoler, si le nom se termine par un '_', on l'elimine
if(dirname(length(dirname)) == '_')
    dirname(length(dirname)) = '';
end
