function data = collectOnlineSpikes(directory, maxSweep)
% collect data from benware spike files

if ~exist('maxSweep', 'var')
	maxSweep = Inf;
end

l = load([directory '/gridInfo.mat']);
expt = l.expt;
grid = l.grid;

nSets = size(grid.stimGrid, 1);
nChannels = expt.nChannels;

sets = {};
for setIdx = 1:nSets
	fprintf('Set %d\n', setIdx);
	sets{setIdx}.stimGridTitles = grid.stimGridTitles;
	sets{setIdx}.stimParams = grid.stimGrid(setIdx,:);
	sweepIndices = find(grid.randomisedGridSetIdx==setIdx)';

	spikeTimes = cell(1, nChannels);

	for sweepNum = sweepIndices
		if sweepNum>maxSweep
			continue
		end

		try
			fprintf('Trying to load sweep %d...', sweepNum);
			l = load([directory '/' fix_slashes(constructDataPath(expt.sweepFilename, grid, expt, sweepNum, 0))]);
			for channelNum = 1:nChannels
				if isempty(spikeTimes{channelNum})
					spikeTimes{channelNum}{1} = l.sweep.spikeTimes{channelNum};
				else
					spikeTimes{channelNum}{end+1} = l.sweep.spikeTimes{channelNum};
				end
			end
			fprintf('success\n');
		catch
			fprintf('failed\n');
			break
		end
	end

	sets{setIdx}.spikeTimes = spikeTimes;
end

sets = [sets{:}];

data.expt = expt;
data.grid = grid;
data.sets = sets;