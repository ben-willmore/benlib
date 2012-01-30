function metadata = saveBWVTmetadata(dir)
%% get metadata from BWVT files and save it in metadata.mat
%% only for BWVTs with one file per sweep/channel combo

pattern = '001-swp0000.bwvt';
files = getfilesmatching([dir filesep '*' pattern '*']);


metadata.sweeps = [];
metadata.n_channels = nan;

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
    filepattern = [st '%n-swp' num2str(sweep, '%04d') '.bwvt' en];
    filename = regexprep(filepattern, '%n', '001');
    pathname = [dir filesep filename];
    if ~exist(pathname, 'file')
      found_data = false;
      continue;
    end
    
    if isnan(metadata.n_channels)
      fprintf('Counting channels...\n');
      found_chan = true;
      chan = 0;
      while found_chan
        chan = chan + 1
        chanfilename = regexprep(filepattern, '%n', num2str(chan, '%03d'));
        chanpathname = [dir filesep chanfilename];
        if ~exist(chanpathname, 'file')
          found_chan = false;
          continue;
        end
      metadata.n_channels = chan
      end
    end
    
    bwvt = bwvtFileGunzipAndRead(pathname);
    if isempty(bwvt)
      fprintf('Empty bwvt file!\n');
      continue;
    end
    bwvt = rmfield(bwvt, 'signal');
    
    bwvt.dataFilepattern = filepattern;
    if isempty(metadata.sweeps)
      metadata.sweeps = bwvt;
    else
      metadata.sweeps(end+1) = bwvt;
    end
  end
  fprintf(' found %d sweeps\n', sweep);
    
end

try
  save([dir filesep 'metadata.mat'], 'metadata');
catch
  fprintf('Couldn''t save metadata file --- permissions problem?\n');
end
