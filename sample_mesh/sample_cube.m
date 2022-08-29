%%% Sampling points on the cube and saving them to file:

% Number of points to sample:
n = 100000;

% Sample points:
pos = rand(n, 3);

pos = pos * 2 - 1;

% Max coordinate for each point:
pos_max = repmat(max(abs(pos), [], 2), 1, 3);
ind_max = (abs(pos) == pos_max);

% Project points on the cube's wall:
pos = pos ./ repmat(max(abs(pos), [], 2), 1, 3);

% Set normals according to maximum coordinate:
normals = (abs(pos) == repmat(max(abs(pos), [], 2), 1, 3)) .* pos;

savename = 'cube100k';

% Save sampled points:
dlmwrite([savename '.xyz'], pos, 'precision', '%.6f', 'delimiter', ' ');
% Save normals:
dlmwrite([savename '.normals'], normals, 'precision', '%.6f', 'delimiter', ' ');
