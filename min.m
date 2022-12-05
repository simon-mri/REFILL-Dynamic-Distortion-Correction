%MIN    Minimum elements of an array.
%   M = MIN(X) is the smallest element in the vector X. If X is a matrix,
%   M is a row vector containing the minimum element from each column. For 
%   N-D arrays, MIN(X) operates along the first non-singleton dimension.
%
%   When X is complex, the minimum is computed using the magnitude
%   MIN(ABS(X)). In the case of equal magnitude elements the phase angle 
%   MIN(ANGLE(X)) is used.
%
%   [M,I] = MIN(X) also returns the indices into operating dimension 
%   corresponding to the minimum values. If X contains more than one 
%   element with the minimum value, then the index of the first one 
%   is returned.
%
%   C = MIN(X,Y) returns an array with the smallest elements taken from X 
%   or Y. X and Y must have compatible sizes. In the simplest cases, they 
%   can be the same size or one can be a scalar. Two inputs have compatible 
%   sizes if, for every dimension, the dimension sizes of the inputs are 
%   either the same or one of them is 1.
%
%   M = MIN(X,[],'all') returns the smallest element of X.
%
%   M = MIN(X,[],DIM) or [M,I] = MIN(X,[],DIM) operates along the 
%   dimension DIM.
%
%   M = MIN(X,[],VECDIM) operates on the dimensions specified in the vector 
%   VECDIM. For example, MIN(X,[],[1 2]) operates on the elements contained
%   in the first and second dimensions of X.
%
%   C = MIN(X,Y,NANFLAG) or M = MIN(X,[],...NANFLAG) or 
%   [M,I] = MIN(X,[],NANFLAG) or [M,I] = MIN(X,[],DIM,NANFLAG) specifies 
%   how NaN (Not-A-Number) values are treated. NANFLAG can be:
%   'omitnan'    - (default) Ignores all NaN values and returns the minimum
%                  of the non-NaN elements.  If all elements are NaN, then
%                  the first one is returned.
%   'includenan' - Returns NaN if there is any NaN value.  The index points
%                  to the first NaN element.
%
%   [M,I] = MIN(X,[],...,'linear') returns the linear indices of the 
%   minimum values in vector I.
%
%   Example: 
%       X = [2 8 4; 7 3 9]
%       min(X,[],1)
%       min(X,[],2)
%       min(X,5)
%
%   See also MAX, BOUNDS, CUMMIN, MEDIAN, MEAN, SORT, MINK.

%   Copyright 1984-2018 The MathWorks, Inc.
%   Built-in function.
