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
  if isstr(varargin{end}) || isscalar(varargin{end})
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

if isa(fn, 'function_handle')
  % then we have a single function 
  fns = {fn};
  args = {varargin};
elseif isstr(fn)
  % then we have a single function 
  fns = {str2func(fn)};
  args = {varargin};
elseif iscell(fn)
  % then we have a cell array of functions
  fns = {};
  for ii = 1:length(fn)
    if isa(fn, 'function_handle')
      fns{ii} = fn{ii};
    else
      fns{ii} = str2func(fn{ii});
    end
  end
  assert(length(varargin)<=1);
  args = varargin{1};
end

% find files matching filespec (unless it is already a list)
if isstr(filespec)
  files = getfilesmatching(filespec);
else
  files = filespec;
end

% construct commands
cmds = {};
for fnIdx = 1:length(fns)
  fn = fns{fnIdx};
  fnstr = func2str(fn);
  
  if isempty(args)
    arg = {};
  else
    arg = args{fnIdx};
  end
  
  for fileIdx = 1:length(files)
    file = files{fileIdx};

    cmd = struct;
    cmd.cell = {fn, file, arg{:}};
    cmd.fnstr = fnstr;

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
    cmd.strdot = sprintf('%s.%s', func2str(fn), paramsdot);
    if isempty(paramscomma)
      cmd.strcomma = sprintf('%s(''%s'')', fnstr, file);
    else
      cmd.strcomma = sprintf('%s(''%s'', %s)', fnstr, file, paramscomma);
    end
    cmds{end+1} = cmd;
  end
end
cmds = [cmds{:}];

% create log dir if it doesn't exist
logdir = './batch.log';
if ~exist(logdir, 'dir')
  mkdir(logdir);
end

% logfile filename
if length(fns)==1
  logfile = [logdir filesep datestr(now, 'yyyy.mm.dd_HH.MM') '.' ...
	   cmd(1).strdot 'log'];
else
  logfile = [logdir filesep datestr(now, 'yyyy.mm.dd_HH.MM') '.multiple.log'];
end

% start saving output to logfile
diary(logfile);

% reverse order in which files will be processed
if reverse
  cmds = flipud(cmds);
end

% do it
nargs = nargout(fn);
result = {};

% loop through files
if ~parallel
  % not parallel

  for ii = 1:length(cmds)
    cmd = cmds(ii);

    fprintf('== %s: Running %s ...\n', datestr(now, 'yyyy.mm.dd HH.MM'), cmd.strcomma);

    try
      if nargs==0
        feval(cmd.cell{:});
      elseif nargs<0 || nargs==1
        out = feval(cmd.cell{:});
        result{end+1} = out;
      else
        [out{1:nargs}] = feval(cmd.cell{:});
        result{end+1} = out;
      end
      
      fprintf('-> %s: success\n\n', cmd.strcomma);

    catch
      warning(lasterr);
      fprintf('-> %s: failure\n\n', cmd.strcomma);

    end

    if shouldPause;
        fprintf('Pausing...')
        pause;
        fprintf('\n');
    end
  end

else
  % parallel

  parfor ii = 1:length(cmds)

    if ii==length(files)
      fprintf('!! Queueing last job\n');
    end

    t = getCurrentTask();
    worker = t.ID;

    cmd = cmds(ii);
    fprintf('== %s, Lab %d: Running %s ...\n', datestr(now, 'yyyy.mm.dd HH.MM'), worker, cmd.strcomma);

    try
      feval(cmd.cell{:});    
      fprintf('-> % Lab %d: %s -> success\n\n', datestr(now, 'yyyy.mm.dd HH.MM'), worker, cmd.strcomma);

    catch
      warning(lasterr);
      fprintf('-> % Lab %d: %s -> failure\n\n', datestr(now, 'yyyy.mm.dd HH.MM'), worker, cmd.strcomma);

    end

  end

end

diary off;

if length(result)
 [varargout{1:nargout}] = result;
end
