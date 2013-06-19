function h = subplottight(m,n,p,separation, margin)

if ~exist('separation','var')
  separation = .1;
end

if ~exist('margin', 'var')
	margin = .05;
end

xnum = mod(p-1,n)+1;
ynum = floor((p-1)/n)+1;

xboxwid = (1-2*margin)/n;
yboxwid = (1-2*margin)/m;

xplotwid = xboxwid*(1-separation);
yplotwid = yboxwid*(1-separation);

xboxmargin = (xboxwid-xplotwid)/2;
yboxmargin = (yboxwid-yplotwid)/2;

xmin = margin + xboxwid*(xnum-1) + xboxmargin;
ymin = 1 - (margin + yboxwid*(m-ynum) + yboxmargin);

h = subplot('position',[xmin 1-ymin xplotwid yplotwid]);
