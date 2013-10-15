function h = stepplot(x,y)

xt = repmat(x,[2 1]);
xp = [xt(:); xt(end)+1; xt(end)+1];

yt = repmat(y, [2 1]);
yp =  [0; yt(:); 0];

size(xp)

size(yp)

h = plot(xp,yp);
