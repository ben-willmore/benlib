function varargout = batchmode(fn, filespec, varargin)
% function batchmode(fn, filepattern, varargin)
% 
% Applies a function to all files matching filepattern
% 
% Inputs:
%  fn -- function name or handle
%  filespec -- pattern the files should match, or list of files
%  varargin -- parameters that will be passed to fn
%  ..., 'reverse' or 'flip' -- last argument should be one of these
%    if you want the files to be processed in reverse order

% e.g. batchmode('compute_csdkernel', './metadata/*.mat', 10, 6.25, 6.25)

reverse = false;
shouldPause = false;
if feature('ShowFigureWindows')
  % by default, use parallel processing if matlab was called with -nodisplay
  parallel = false;
else
  % by default, otherwise, no parallel
  parallel = true;
end
poolsize = Inf;

done = false;
while ~isempty(varargin) && ~done
  if strcmp(varargin{end}, 'reverse') || strcmp(varargin{end}, 'flip')
    reverse = true;
    varargin = varargin(1:end-1);
  elseif strcmp(varargin{end}, 'pause')
    % ignored if parallel==true
    shouldPause = true;
    varargin = varargin(1:end-1);
  elseif strcmp(varargin{end}, 'parallel')
    parallel = true;
    varargin = varargin(1:end-1);
  elseif strcmp(varargin{end}, 'noparallel')
    parallel = false;
    varargin = varargin(1:end-1);
  elseif length(varargin)>1 && strcmpi(varargin{end-1}, 'poolsize')
    poolsize = varargin{end};
    varargin = varargin(1:end-2);
  else
    done = true;
  end
end

falsetrue = {'false','true'};
fprintf('parallel=%s, pause=%s, reverse=%s, poolsize=%d\n', ...
  falsetrue{parallel+1}, falsetrue{shouldPause+1}, falsetrue{reverse+1}, poolsize);

if parallel
  % attempt to open a pool
  if matlabpool('size') ~= 0
    matlabpool close;
  end

  if isinf(poolsize)
    matlabpool;
  else
    matlabpool(poolsize);
  end

  pause(2);
end 

if isstr(fn)
  fnstr = fn;
else
  fnstr = func2str(fn);
end

% create log dir if it doesn't exist
logdir = './batch.log';
if ~exist(logdir, 'dir')
  mkdir(logdir);
end

% overcomplicated formatting of parameters for printing in log file
paramsdot = [];
paramscomma = [];
for ii = 1:length(varargin)
  if isstr(varargin{ii})
    pstr = varargin{ii};
    paramsdot = [paramsdot pstr '.'];
    paramscomma = [paramscomma ', ''' pstr ''''];
  elseif isnumeric(varargin{ii}) && isscalar(varargin{ii})
    pstr = num2str(varargin{ii});
    paramsdot = [paramsdot pstr '.'];
    paramscomma = [paramscomma ', ' pstr];
  else
    pstr = '.';
  end
end

% logfile filename
logfile = [logdir filesep datestr(now, 'yyyy.mm.dd_HH.MM') '.' ...
	   fnstr '.' paramsdot 'log'];
	   
% start saving output to logfile
diary(logfile);

% find files matching filespec (unless it is already a list)
if isstr(filespec)
  files = getfilesmatching(filespec);
else
  files = filespec;
end

% reverse order in which files will be processed
if reverse
  files = flipud(files);
end

% do it
nargs = nargout(fn);
result = {};

% loop through files
if ~parallel
  % not parallel
  for ii = 1:length(files)
    file = files{ii};
    fprintf(['== ' datestr(now, 'yyyy.mm.dd HH.MM') ': Running ' fnstr '(''' file '''' paramscomma ') ...\n']);

    try
      if nargs==0
        feval(fn, file, varargin{:});
      elseif nargs<0 || nargs==1
        out = feval(fn, file, varargin{:});
        result{end+1} = out;
      else
        [out{1:nargs}] = feval(fn, file, varargin{:});
        result{end+1} = out;
      end
      
      fprintf(['-> ' fnstr ' ' file  ' success\n\n']);

    catch
      warning(lasterr);
      fprintf(['-> ' fnstr ' ' file  ' failure\n\n']);

    end
    
    if shouldPause;
        fprintf('Pausing...')
        pause;
        fprintf('\n');
    end
  end

else
  % parallel

  parfor ii = 1:length(files)
    if ii==length(files)
      fprintf('!! Queueing last job\n');
    end

    t = getCurrentTask();
    worker = t.ID;
    file = files{ii};
    fprintf(['== ' datestr(now, 'yyyy.mm.dd HH.MM') ', Lab ' num2str(worker) ': Running ' fnstr '(''' file '''' paramscomma ') ...\n']);

    try
      feval(fn, file, varargin{:});      
      fprintf(['-> ' datestr(now, 'yyyy.mm.dd HH.MM') ', Lab ' num2str(worker) ': ' fnstr ' ' file  ' success\n\n']);

    catch
      warning(lasterr);
         fprintf(['-> ' datestr(now, 'yyyy.mm.dd HH.MM') ', Lab ' num2str(worker) ': ' fnstr ' ' file  ' success\n\n']);

    end

  end

end

diary off;

try
  result = [result{:}];
end

if length(result)
 [varargout{1:nargout}] = result;
end
