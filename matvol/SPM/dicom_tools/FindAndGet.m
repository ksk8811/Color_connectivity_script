function value = FindAndGet(charfilecontent, Paramstr)
% function value = FindAndGet(charfilecontent, Paramstr)
%
% Function to extract file contents from the ASCII part of the file
%

ascii_param_pos = findstr(charfilecontent, '### ASCCONV BEGIN ###') + 31;
tpos = findstr(charfilecontent([ascii_param_pos]:[end]), Paramstr);
tstring = sscanf(charfilecontent([tpos + ascii_param_pos]:[end]), '%s', 3);
t2pos = findstr(tstring, '=');
tstringl = length(tstring);
charval = tstring([t2pos + 1]:tstringl);
value = str2num(charval);
