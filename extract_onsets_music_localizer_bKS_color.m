% selectionner dans edat2 les colonnes suivantes:
% (avec remove all, alphabetize, select, add)
% image1.OnsetTime;image2.OnsetTime;image3.OnsetTime;typemanip[SubTrial];image1.RT;image2.RT;image3.RT
% les Copier-coller dans excel dans cet ordre
% Remplacer NULL par 0
% Copie-coller les 7 colonnes
% dans la variable matlab 'a'

clear
clc

cd('/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/Onsets');
T = readtable('1023_color.xlsx');


Vars_of_interest = {'image1.OnsetTime';'image2.OnsetTime';'image3.OnsetTime';'typemanip[SubTrial]';'image1.RT';'image2.RT';'image3.RT'}';
Vars_of_interest = strrep(Vars_of_interest, '.', '_');
Vars_of_interest = strrep(Vars_of_interest, '[', '_');
Vars_of_interest = strrep(Vars_of_interest, ']', '_');

I = find(ismember( T.Properties.VariableNames, Vars_of_interest));
I = [I, 2];


allSubs = T(:,I);

allSubs = allSubs(1:end-1,[1 3 5 7 2 4 6 8]);% rearrange columns, and erase last row where there is an F in TLL
allSubs = fillmissing(allSubs, 'constant', 0);
subs = unique(allSubs.Subject);

%%
for s = 1:length(unique(allSubs.Subject))
    a = allSubs(allSubs.Subject==subs(s), :);
    a = table2array(a(:, 1:7));
    aa=[a(:,1); a(:,2); a(:,3) ]; % concat???ne les onsets
    aaa=sort(aa); % range les onsets par ordre croissant
    aaaa = aaa([true;logical(diff(aaa(:,1)))],:); % supprime les onsets r?p?t?s
    allonsets=aaaa(2:length(aaaa)) ; % enl???ve le 0 initial
    initial=allonsets(1);% premier onset de chaque s???quence
    allonsets=(allonsets-initial)/1000;
    
    c= a(:,4); % cat???gories des stimuli associ???s aux onsets
    cc=c([true;logical(diff(c(:,1)))],:); % supprime les valeurs r?p?t?es, ne laisse qu'une valeur par minibloc
    ccc= cc(find(cc~=1)); % supprime la cat???gorie "repos"
    types=reshape(repmat(ccc',8,1),length(allonsets),1); % r???plique 8 fois chaque valeur pour associer une cat???gorie ??? chaque onset
    
    % compute onsets of button presses
    a(:,8:10)=a(:,1:3)+a(:,5:7);
    a(:,11:13)=a(:,8:10).*(a(:,5:7)>0);
    b=sum(a(:,11:13),2);
    b=b(b>0);
    b=(b-initial(1))/1000;
    
    % objectWCOL	8
    % objectGS    2
    % mondriansGS	5
    % mondriansCOL	4
    % objectCOL	7
    
    names={'objectWCOL','objectGS','mondriansGS','mondriansCOL','objectCOL','buttonpress'};
    
    onsets_mat_file='onsets_color'; % nom de la matrice d'onsets
    
    onsets{1}=allonsets(find(types==8));
    onsets{2}=allonsets(find(types==2));
    onsets{3}=allonsets(find(types==5));
    onsets{4}=allonsets(find(types==4));
    onsets{5}=allonsets(find(types==7));
    onsets{6}=b;
    
    for u=1:6
        durations{u}=zeros(length(onsets{u}),1);
    end
    
    onsetDir = ['/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/Processed_566_471_vol/' num2str(subs(s)) '/Onsets'];
    
    if ~exist(onsetDir, 'dir')
        mkdir(onsetDir)
    end
    
    cd (onsetDir)
    
    cmd=['save ''' , onsets_mat_file,'.mat', ''' names onsets durations'];
    eval(cmd);
end
