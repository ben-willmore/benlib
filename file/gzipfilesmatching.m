function gzipfilesmatching(pattern)

filenames = getfilesmatching(pattern);

for ii = 1:length(filenames)
  file = filenames{ii};
  gzip(file);
  delete(file);
end