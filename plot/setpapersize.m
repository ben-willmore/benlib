function setpapersize(width,height)
% set paper size for printing
% arguments width, height in centimetres
% or 'a4'

if isstr(width)
	if strcmp(lower(width), 'a4')
		width = 27;
		height = 18;
	end
end

set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 width height]);

if width>height
	orient landscape
else
	orient portrait
end