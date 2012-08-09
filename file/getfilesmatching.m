function files = getfilesmatching(pattern)
% get files matching a unix pattern

if ispc
   strings = ls(pattern);
   list = [];

   f = find(pattern==filesep, 1, 'last');
   dirname = pattern(1:f);
   
   for ii = 1:size(strings, 1);
       % strip trailing spaces
       filename = regexprep(strings(ii, :), '\s*$', '');
       
       % add directory name
       list = [list dirname filename sprintf('\t')];
   end
   % strip trailing tab character
   if length(list)>0
       list = list(1:end-1);
   end
else
    list = ls(pattern);
end

[st, en] = regexp(list,'\S*');

files = {};
for ii = 1:length(st)
  files{ii} = list(st(ii):en(ii));
end

files = sort(files)';
