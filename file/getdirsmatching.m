function files = getdirsmatching(pattern)
% get files matching a unix pattern

list = ls('-d', pattern);
[st, en] = regexp(list,'\S*');

files = {};
for ii = 1:length(st)
  files{ii} = list(st(ii):en(ii));
end

files = sort(files)';
