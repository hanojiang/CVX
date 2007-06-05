%%*************************************************************************
%% linsysolvefun: Solve H*x = b
%%
%% x = linsysolvefun(L,b)
%% where L contains the triangular factors of H. 
%%
%% SDPT3: version 3.1
%% Copyright (c) 1997 by
%% K.C. Toh, M.J. Todd, R.H. Tutuncu
%% Last Modified: 16 Sep 2004
%%*************************************************************************
 
  function x = linsysolvefun(L,b)
 
  x = zeros(size(b)); 
  for k=1:size(b,2)
     if strcmp(L.matfct_options,'chol')
        x(L.perm,k) = mextriang(L.R, mextriang(L.R,b(L.perm,k),2) ,1); 
        %%x(L.perm,k) = L.R \ (b(L.perm,k)' / L.R)';
     elseif strcmp(L.matfct_options,'spcholmatlab')
        x(L.perm,k) = mextriangsp(L.Rt,mextriangsp(L.R,b(L.perm,k),2),1);
     elseif strcmp(L.matfct_options,'spchol')
        x(:,k) = bwblkslvfun(L, fwblkslvfun(L,b(:,k)) ./ L.d);
     elseif strcmp(L.matfct_options,'lu')
        x(:,k) = L.u \ (L.l \ b(L.perm,k));
     elseif strcmp(L.matfct_options,'splu')    
	if (L.symmatrix)
           %% coefficient matrix is symmetric
	   %% A = P'*L*U*Q' --> A = Q*U'*L'*P 
   	   btmp = b(L.perm,k);
           xtmp = mextriangsp(L.l,mextriangsp(L.u,btmp(L.q),2),1);
           x(L.perm,k) = xtmp(L.p); 
	else
           x(L.perm,k) = L.q*( L.u \ (L.l \ (L.p*b(L.perm,k))));
        end
     end
  end
%%*************************************************************************
