function col = bluered(nsteps, step)

	blue = [0 0 1];

	red  = [1 0 0];

	proportion = (step-1)/(nsteps-1);
	col = blue*(1-proportion) + red*proportion;
