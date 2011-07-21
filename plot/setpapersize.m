function setpapersize(width,height)
% set paper size for printing
% arguments width, height in centimetres

set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 width height]);
