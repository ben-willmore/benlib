function varargout = imagescn(varargin)
% function varargout = imagescn(varargin)
%
% imagesc but with colour axes that are 
% symmetric about zero

  h = imagesc(varargin{:});
  im = varargin{1};
  mx = max(abs(im(:)));
  try
	  clim([-mx mx]);
  end
  
  if nargout == 1
  	varargout = {h};
  end
