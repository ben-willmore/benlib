function addbasicmetadata(dirname)

  dirpath = GetFullPath(dirname);

  sp = splitstr('/', dirname);
  exptdir = sp{end-1};
  [d1, d2, d3, d4, exptnum] = regexp(exptdir, '([0-9]*$)');
  metadata.exptnum = str2num(exptnum{1}{1});

  pendir = sp{end};
  [d1, d2, d3, d4, penid] = regexp(pendir, '^(P[0-9]*)');
  metadata.penid = penid{1}{1};

  % bilateral or unilateral data
  i = demandinput('Bilateral or unilateral? [b/u] ', 'bu');
  if strcmp(lower(i), 'b')
    metadata.electrode_arrangement = 'bilateral';
  else
    metadata.electrode_arrangement = 'unilateral';
  end

  % cortex or IC?
  i = demandinput('Cortex or IC? [c/i] ', 'ci');
  if strcmp(lower(i), 'c');
    metadata.area = 'cortex';
  else
    metadata.area = 'ic';
  end

  % number of channels
  metadata.n_channels = nan;
  pattern = '001-swp0000.bwvt';
  files = getfilesmatching([dirname filesep '*' pattern '*']);
  file = files{1};
  sweep = 1;
  s = splitstr(filesep, file);
  s = s{end};
  f = findstr(s, pattern);
  st = s(1:f-1);
  en = s(f+length(pattern):end);
  filepattern = [st '%n-swp' num2str(sweep, '%04d') '.bwvt' en];
  filename = regexprep(filepattern, '%n', '001');
  fprintf('Counting channels...\n');
  found_chan = true;
  chan = 0;
  while found_chan
    chan = chan + 1;
    chanfilename = regexprep(filepattern, '%n', num2str(chan, '%03d'));
    chanpathname = [dirname filesep chanfilename];
    if ~exist(chanpathname, 'file')
      found_chan = false;
      continue;
    end
    metadata.n_channels = chan;
  end

  if strcmp(metadata.electrode_arrangement, 'bilateral')
    metadata.electrode_channels = [1:metadata.n_channels/2; ...
                        metadata.n_channels/2+1:metadata.n_channels];
  else
    metadata.electrode_channes = 1:metadata.n_channels;
  end

  % save
  i = demandinput('OK to save? [y/n] ', 'yn');
  if strcmp(lower(i), 'y')
    updatemetadatafile([dirname filesep 'metadata.mat'], metadata);
  else
    fprintf('Doing nothing\n');
  end