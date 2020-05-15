Compilation on Windows 10 x64, May 2020

Install Matlab 2020a

Install MS Visual C++ community edition
-- C++ for desktop component

Install Intel Parallel Studio XE 2020
-- requires the above

In matlab:
mex -setup FORTRAN
Edit c:\Users\Ben\AppData\Roaming\MathWorks\MATLAB\R2020a\mex_FORTRAN_win64.xml
Add /real_size:64 /integer_size:64 to the end of COMPFLAGS=... (two locations)
cd glmnet
mex -largeArrayDims glmnetMex.F GLMnet.f 


----

This was based on these instructions from Stanford:

Platform: Windows 7 Professional SP1 (64-bit), Intel Core i7 3.40GHz

Matlab version: Matlab 2013b (64-bit)

Compiler: Intel Visual Fortran Composer XE 2013

Note that the glmnet Fortran source file uses real, integer to define respectively real, integer variables and functions. To build Mex-files on 64-bit Windows systems, we follow the steps as below.

1. Choose the correct compiler (Intel Visual Fortran Composer XE 2013 here)

2. Locate the option file mexopt.bat and add /real_size:64 /integer_size:64 to the end of COMPFLAGS=... term

3. In Matlab, change to the correct directory and type

mex -largeArrayDims glmnetMex.F GLMnet.f 

to build the Mex-files on 64-bit systems.
