function saveBWVTmetadata(dir)
%% get metadata from BWVT files and save it in metadata.mat

pattern = '001-swp0000.bwvt';
files = getfilesmatching([dir filesep '*' pattern '*']);

metadata = [];
for file = files'
  fprintf('Reading files like %s...', file{1});
  s = splitstr(filesep, file{1});
  s = s{end};
  f = findstr(s, pattern);
  st = s(1:f-1);
  en = s(f+length(pattern):end);
  
  sweep = 0;
  found_data = true;

  while found_data
    sweep = sweep + 1;
    filename = [st '001-swp' num2str(sweep, '%04d') '.bwvt' en];
    pathname = [dir filesep filename];
    if ~exist(pathname, 'file')
      found_data = false;
      continue;
    end
    
    bwvt = bwvtFileGunzipAndRead(pathname);
    if isempty(bwvt)
      fprintf('Empty bwvt file!\n');
      continue;
    end
    bwvt = rmfield(bwvt, 'signal');
    
    bwvt.dataFilename = filename;
    if isempty(metadata)
      metadata = bwvt;
    else
      metadata(end+1) = bwvt;
    end
  end
  fprintf(' found %d sweeps\n', sweep);
    
end

keyboard;
save([dir filesep 'metadata.mat'], 'metadata');
