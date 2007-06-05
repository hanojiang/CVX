function cvx_optval = huber( x, M, t )
error( nargchk( 1, 3, nargin ) );

% HUBER   Huber penalty function.
%     For a real or complex scalar X, HUBER(X) is the Huber penalty
%     function applied to X: that is,
%
%         HUBER(X) = |X|^2   if |X|<=1,
%                    2|X|-1  if |X|>=1.
%
%     HUBER(X,M) is the Huber penalty function of halfwidth M applied to X;
%     that is, HUBER(X,M)=M.^2.*HUBER(X./M).
%
%     HUBER(X,M,T) computes T.*HUBER(X./T,M), the perspective transformation
%     of HUBER(X,M). This is useful for solving regression problems with
%     concomitant scale. T is constrained to be nonnegative.
%
%     For matrices and N-D arrays, the penalty function is applied to each
%     element of X independently. M and X must be compatible in the same
%     sense as .*: one must be a scalar, or they must have identical size.
%
%     Disciplined convex programming information:
%         HUBER is convex and nonmonotonic; therefore, when used in CVX
%         specifications, its argument must be affine.

%
% Check types
%

if nargin < 2,
    M = 1;
elseif ~isnumeric( M ),
    error( 'Second argument must be numeric.' );
elseif ~isreal( M ) | any( M( : ) <= 0 ),
    error( 'Second argument must be real and positive.' );
end

if nargin < 3,
    t = 1;
elseif ~isreal( t ),
    error( 'Third argument must be real.' );
elseif cvx_isconstant( t ) & nnz( cvx_constant( t ) <= 0 ),
    error( 'Third argument must be real and positive.' );
end

if ~cvx_isaffine( x ) | ~cvx_isaffine( t ),
    error( sprintf( 'Disciplined convex programming error:\n    HUBER is convex and nonmonotonic; its arguments must therefore be affine.' ) );
end

%
% Check sizes
%

sx = size( x ); xs = all( sx == 1 );
sM = size( M ); Ms = all( sM == 1 );
st = size( t ); ts = all( st == 1 );
if ~xs, sz = sx; elseif ~Ms, sz = sM; else sz = st; end
if ~( xs | isequal( sz, sx ) ) | ~( Ms | isequal( sz, sM ) ) | ~( ts | isequal( sz, st ) ),
   error( 'Sizes are incompatible.' );
end

%
% Compute result
%

cvx_begin
    variables v( sz ) w( sz )
    minimize( quad_over_lin( w, t, 0 ) + 2 .* M .* v )
    abs( x ) <= w + v;
    w <= M * t;
    v >= 0;
cvx_end

% Copyright 2005 Michael C. Grant and Stephen P. Boyd.
% See the file COPYING.txt for full copyright information.
% The command 'cvx_where' will show where this file is located.
