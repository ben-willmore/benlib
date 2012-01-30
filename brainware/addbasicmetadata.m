function addbasicmetadata(dirname)

dirpath = GetFullPath(dirname);

sp = splitstr('/', dirname);
exptdir = sp{end-1};
[d1, d2, d3, d4, exptnum] = regexp(exptdir, '([0-9]*$)');
metadata.exptnum = str2num(exptnum{1}{1});

pendir = sp{end};
[d1, d2, d3, d4, penid] = regexp(pendir, '^(P[0-9]*)');
metadata.penid = penid{1}{1};


i = demandinput('Bilateral or unilateral? [b/u] ', 'bu');
if strcmp(lower(i), 'b')
  metadata.electrode_arrangement = 'bilateral';
else
  metadata.electrode_arrangement = 'unilateral';
end

i = demandinput('Cortex or IC? [c/i] ', 'ci');
if strcmp(lower(i), 'c');
  metadata.area = 'cortex';
else
  metadata.area = 'ic';
end

metadata

updatemetadatafile([dirname filesep 'metadata.mat'], metadata);
