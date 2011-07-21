function data = readf32(filename)

f = fopen(filename,'r');
if (f==-1)
  disp('Could not open file');
  data = nan;
  return
else
  data = fread(f,Inf,'float32');
  fclose(f);
end
