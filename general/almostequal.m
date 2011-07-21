function bool = almostequal(x,y)
% check whether two matrices are equal to within
% matlab's tolerance (eps)

bool = abs(x-y)<eps;
