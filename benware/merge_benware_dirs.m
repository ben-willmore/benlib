function merge_benware_dirs(dir1, dir2)

% temporary directory for result of merge
tmpdir = tempname('.');
mkdir(tmpdir);

files = getfilesmatching([dir2 '/raw.f32/*.f32']);

% check for conflicting filenames
for ii = 1:length(files)
  file = files{ii};
  [dirname, leafname] = split_path(file);
  if exist([dir1 '/raw.32/' leafname])
    error(['Conflicting filename: ' leafname]);
  end
end

mkdir([tmpdir '/raw.f32']);

% copy files from dir1/raw.f32
files = getfilesmatching([dir1 '/raw.f32/*.f32']);
for ii = 1:length(files)
  file = files{ii};
  [dirname, leafname] = split_path(file);
  copyfile(file, [tmpdir '/raw.f32/' leafname]);
end

% copy files from dir2/raw.f32
files = getfilesmatching([dir2 '/raw.f32/*.f32']);
for ii = 1:length(files)
  file = files{ii};
  [dirname, leafname] = split_path(file);
  copyfile(file, [tmpdir '/raw.f32/' leafname]);
end


%  movefile(