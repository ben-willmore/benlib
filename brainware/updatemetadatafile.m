function updatemetadatafile(filename, newmetadata)

if exist(filename, 'file')
  l = load(filename);
  metadata = l.metadata;
else
  metadata = struct;
end
  
fnames = fieldnames(newmetadata);

for fname = fnames'
  setfield(metadata, fname, getfield(newmetadata, fname));
end
movefile(filename, [filename  '.old.mat']);
save(filename, 'metadata');
