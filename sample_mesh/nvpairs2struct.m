% validnames can also be a struct with the default parameter values
% can also return indices into the arguments list instead of the actual
% values, for performance when the arguments are very large
% unexpected:
% -1 => error
%  0 => skip
%  1 => add
% notpairs:
% -1 => error
%  0 => skip
function [nameval,nvmask] = nvpairs2struct(args,expectednames,returninds,unexpected,notpairs)
    if nargin < 2
        expectednames = {};
    end
    if nargin < 3 || isempty(returninds)
        returninds = false;
    end
    if nargin < 4 || isempty(unexpected)
        unexpected = -1;
    end
    if nargin < 5 || isempty(notpairs)
        notpairs = -1;
    end

    if mod(numel(args),2) ~= 0
        error('Invalid number of arguments for name/value pairs.')
    end

    if isstruct(expectednames)
        nameval = expectednames;
        expectednames = fieldnames(nameval);
    else
        nameval = struct;
    end
    
    nvmask = false(numel(args));
    for i=1:2:numel(args)%numel(args)-1:-2:1
        if not(ischar(args{i}))
            if notpairs == -1
                error('Not all inputs seem to be name/value pairs.');
            else
                continue;
            end
        end
        if unexpected <= 0 && not(isempty(expectednames)) && not(any(strcmp(args{i},expectednames)))
            if unexpected == -1
                error(['Unexpected parameter ''',args{i},'''.']);
            elseif unexpected == 0
                continue; % ignore and do not add to output
            end
        end
        if returninds
            nameval.(args{i}) = i+1;
        else
            nameval.(args{i}) = args{i+1};
        end
        nvmask([i,i+1]) = true;
    end
end
