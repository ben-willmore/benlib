function files = getfilesmatching(pattern)
% get files matching a unix pattern

list = ls(pattern);
[st, en] = regexp(list,'\S*');

files = {};
for ii = 1:length(st)
  files{ii} = list(st(ii):en(ii));
end

files = sort(files)';
