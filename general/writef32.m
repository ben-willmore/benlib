function writef32(data, filename)

f = fopen(filename,'w');
if (f==-1)
  disp('Could not open file');
  data = nan;
  return
else
  fwrite(f, data, 'float32');
  fclose(f);
end
