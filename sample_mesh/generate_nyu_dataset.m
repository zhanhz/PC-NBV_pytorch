function generate_nyu_dataset

    % ind = 45; % bathroom
    % ind = 127; % kitchen
    % ind = 239; % kitchen
    % ind = 261; % living room
    inds = [45,127,239,261];

    % load nyu dataset
    dset = load('../data/shape_sources/nyu_depth_v2_labeled.mat');

    % generate and save nyu point clouds
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

end
