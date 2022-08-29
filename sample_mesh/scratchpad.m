%%
pts = importdata('../data/shapes/cube20k.xyz');
[~,d] = knnsearch(pts,pts,'K',2);
disp(mean(d(:,2)));
% 0.0086 mean nearest neighbor distance for cube20k (this is used as
% standard deviation for the gaussian noise in the paper of Boulch et al.)

%%
pts_noisy = pts + normrnd(0,0.0086,size(pts));

figure;
hold on;
scatter3(pts_noisy(:,1),pts_noisy(:,2),pts_noisy(:,3),'.','SizeData',200);
axis equal;
hold off;

%%
pts1 = importdata('../../data/temp/cube100k.xyz');
% pts2 = importdata('../data/temp/cube100k_noise_brown_1.00e-01.xyz');
% pts2 = importdata('../data/temp/cube100k_noise_brown_5.00e-02.xyz');
% pts2 = importdata('../data/temp/cube100k_noise_brown_1.00e-02.xyz');
% pts2 = importdata('../../data/shapes/cube100k_noise_white_1.00e-02.xyz');
% pts2 = importdata('../../data/shapes/cube100k_noise_white_5.00e-02.xyz');
pts2 = importdata('../../data/shapes/cube100k_noise_white_1.00e-01.xyz');
d = sqrt(sum((pts1-pts2).^2,2)); % since the seed was fixed, corresponding points have same indices
disp(sqrt(mean(d.^2)));
% 0.0239 error standard deviation (euclidean distance) for cube 100k with 0.1 brown noise
% 0.0120 error standard deviation (euclidean distance) for cube 100k with 0.05 brown noise
% 0.0024 error standard deviation (euclidean distance) for cube 100k with 0.01 brown noise

%% save to PLY for poisson reconstruction
name = 'pipe100k';
% name = 'column_head100k_noise_white_5.00e-02';

pts = importdata(['../data/shapes/',name,'.xyz']);

nrm = importdata(['../data/results/t041_50_closer_to_min_loss/',name,'.normals']);
outname = ['../data/',name,'.ply'];

pc_filename = [tempname,'.ply'];
pcloud = pointCloud(pts,'Normal',nrm);
pcwrite(pcloud,pc_filename);

[s,out] = system(['"../poissonrec/PoissonRecon.exe" --in "',pc_filename,'" --out "',outname,'" --depth 10']);
% [s,out] = system(['"../poissonrec/SurfaceTrimmer.exe" --in "',pc_filename,'" --out "',outname,'" --trim 7']);
disp(out);

nrm = importdata(['../data/results/pca_med/',name,'.normals']);
outname = ['../data/',name,'_pca.ply'];

pc_filename = [tempname,'.ply'];
pcloud = pointCloud(pts,'Normal',nrm);
pcwrite(pcloud,pc_filename);

[s,out] = system(['"../poissonrec/PoissonRecon.exe" --in "',pc_filename,'" --out "',outname,'" --depth 10']);
% [s,out] = system(['"../poissonrec/SurfaceTrimmer.exe" --in "',pc_filename,'" --out "',outname,'" --trim 7']);
disp(out);

nrm = importdata(['../data/results/jet_med/',name,'.normals']);
outname = ['../data/',name,'_jet.ply'];

pc_filename = [tempname,'.ply'];
pcloud = pointCloud(pts,'Normal',nrm);
pcwrite(pcloud,pc_filename);

[s,out] = system(['"../poissonrec/PoissonRecon.exe" --in "',pc_filename,'" --out "',outname,'" --depth 10']);
% [s,out] = system(['"../poissonrec/SurfaceTrimmer.exe" --in "',pc_filename,'" --out "',outname,'" --trim 7']);
disp(out);




%% load nyu dataset
dset = load('../data/shape_sources/nyu_depth_v2_labeled.mat');

%% browse nyu dataset (with +/- keys)
browse_nyu_dataset(dset, 1);

%% generate and save nyu point clouds
% ind = 45; % bathroom
% ind = 127; % kitchen
% ind = 239; % kitchen
% ind = 261; % living room
% inds = [45,127,239,261];
inds = [4,38,55,128,140,198];

focallen = [5.8262448167737955e+02; 5.8269103270988637e+02];
principalpoint = [3.1304475870804731e+02; 2.3844389626620386e+02];

for ii=1:numel(inds)
    disp(['rgbd image ', num2str(ii), ' / ', num2str(numel(inds))]);
    
    [y,x] = ndgrid((1:size(dset.depths,1))-0.5, (1:size(dset.depths,2)) - 0.5);
    z = dset.depths(:,:,inds(ii));

    x = ((x - principalpoint(1)) .* z) / focallen(1);
    y = ((y - principalpoint(2)) .* z) / focallen(2);

    p = [x(:), y(:), z(:)];
    dlmwrite(['../data/shapes/nyu_',num2str(inds(ii)),'.xyz'], p, 'precision', '%d', 'delimiter', ' ');
    
    p = p + normrnd(0,0.01,size(p));
    dlmwrite(['../data/shapes/nyu_',num2str(inds(ii)),'_whitenoise.xyz'], p, 'precision', '%d', 'delimiter', ' ');
end

% fig = figure;
% scatter3(p(:,1),p(:,2),p(:,3),'.');
% axis equal;
% set(ax(grid_i,grid_j),'CameraViewAngleMode','Manual')

%% show nyu rgb image
ind = 4;

figure;
imshow(dset.images(:,:,:,ind));


