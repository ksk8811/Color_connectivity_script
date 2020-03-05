function dispsubjectvars(session,onset,cond)
%%%% make a standardized figure for the onsets, sessions and conditions

figure;
subplot(3,1,1);
bar(session);
xlabel('trials');
ylabel('session');
title(strrep(strrep(pwd,'\','\\'),'_','\_'));

subplot(3,1,2);
bar(onset);
xlabel('trials');
ylabel('onsets');

subplot(3,1,3);
bar(cond);
xlabel('trials');
ylabel('conditions');
