function [ A ] = normr( A )
%NORMR Normalize rows of matrix (without neural network toolbox)
%
% Written by Yanir 26/09/2017

n = size(A, 1);

for i=1:n
    vec = A(i, :);
    vec_n = sqrt(sum(vec .* vec));
    A(i, :) = vec / vec_n;
end;

end

