function generate_pcloud_dataset

    [mfiledir,~,~] = fileparts(mfilename);
    addpath(fullfile(mfiledir,'curvature'));

    point_count = 100000;
    seed = 52435234;

    shape_dir = '../data/shapes';
    if exist(shape_dir,'dir')~=7
        error(['Cannot find shape directory ',shape_dir]);
    end

    datasets = struct;
    dataset_ind = 1;

    % mesh dataset
    % (shape name, source type, source type parameters)
    mesh_source_dir = '../data/shape_sources';
    datasets(dataset_ind).shapes = {...
        'cube_uniform', 'mesh', {fullfile(mesh_source_dir,'cube_uniform.off')}; ...
        'flower', 'mesh', {fullfile(mesh_source_dir,'flower.off')}; ...
        'fandisk', 'mesh', {fullfile(mesh_source_dir,'fandisk.off')}; ...
        'bunny', 'mesh', {fullfile(mesh_source_dir,'bunny.off')}; ...
        'armadillo', 'mesh', {fullfile(mesh_source_dir,'armadillo.off')}; ...
        'dragon_xyzrgb', 'mesh', {fullfile(mesh_source_dir,'dragon_xyzrgb.off')}; ...
        'boxunion_uniform', 'mesh', {fullfile(mesh_source_dir,'boxunion_uniform.off')}; ...
        'tortuga', 'mesh', {fullfile(mesh_source_dir,'tortuga.off')}; ...
        'yoda', 'mesh', {fullfile(mesh_source_dir,'yoda.off')}; ...
        'galera', 'mesh', {fullfile(mesh_source_dir,'galera.off')}; ...
        'icosahedron', 'mesh', {fullfile(mesh_source_dir,'icosahedron.off')}; ...
        'Cup33', 'mesh', {fullfile(mesh_source_dir,'Cup33.off')}; ...
        'Cup34', 'mesh', {fullfile(mesh_source_dir,'Cup34.off')}; ...
        'netsuke', 'mesh', {fullfile(mesh_source_dir,'netsuke.off')}; ...
        'sphere', 'mesh', {fullfile(mesh_source_dir,'sphere.off')}; ...
        'cylinder', 'mesh', {fullfile(mesh_source_dir,'cylinder.off')}; ...
        'star_smooth', 'mesh', {fullfile(mesh_source_dir,'star_smooth.off')}; ...
        'star_halfsmooth', 'mesh', {fullfile(mesh_source_dir,'star_halfsmooth.off')}; ...
        'star_sharp', 'mesh', {fullfile(mesh_source_dir,'star_sharp.off')}; ...
        'Liberty', 'mesh', {fullfile(mesh_source_dir,'Liberty.off')}; ...
        'LegoLeg', 'mesh', {fullfile(mesh_source_dir,'LegoLeg.off')}; ...
        'boxunion2', 'mesh', {fullfile(mesh_source_dir,'boxunion2.off')}; ...
        'Boxy_smooth', 'mesh', {fullfile(mesh_source_dir,'Boxy_smooth.off')}; ...
        'box_groove', 'mesh', {fullfile(mesh_source_dir,'box_groove.off')}; ...
        'box_push', 'mesh', {fullfile(mesh_source_dir,'box_push.off')}; ...
        'pipe', 'mesh', {fullfile(mesh_source_dir,'pipe.off')}; ...
        'pipe_curve', 'mesh', {fullfile(mesh_source_dir,'pipe_curve.off')}; ... 
        'column', 'mesh', {fullfile(mesh_source_dir,'column.off')}; ... 
        'column_head', 'mesh', {fullfile(mesh_source_dir,'column_head.off')}; ... 
        };
    datasets(dataset_ind).noise_type = 'white';
    datasets(dataset_ind).min_noise = 0.0;
    datasets(dataset_ind).max_noise = 0.1;
    datasets(dataset_ind).noise_level_count = 11;
    datasets(dataset_ind).density_distribution = {{'uniform'}};
    dataset_ind = dataset_ind + 1;
    
    % separate non-uniform sampling, so we dont get all combinations of
    % noise and non-uniform sampling types
    datasets(dataset_ind).shapes = datasets(dataset_ind-1).shapes;
    datasets(dataset_ind).noise_type = 'white';
    datasets(dataset_ind).min_noise = 0.0;
    datasets(dataset_ind).max_noise = 0.0;
    datasets(dataset_ind).noise_level_count = 1;
    datasets(dataset_ind).density_distribution = {{'minmax',1,0.01}, {'minmax_layers',30,0.1,10}};
    dataset_ind = dataset_ind + 1;
    
    % analytic dataset (separate because variable density is not implemented
    % for analytic shapes)
    datasets(dataset_ind).shapes = {...
        'sphere_analytic', 'analytic', {'roundedcube',struct('r',1,'L',[0,0,0])}; ...
        'cylinder_analytic', 'analytic', {'roundedcube',struct('r',1,'L',[2,0,0])}; ...
        'cube_analytic_sharp', 'analytic', {'roundedcube', struct('r',0.025,'L',[0.95, 0.95, 0.95])}; ...
        'cube_analytic_smooth', 'analytic', {'roundedcube', struct('r',0.1,'L',[0.8, 0.8, 0.8])}; ...
        'sheet_analytic', 'analytic', {'roundedcube', struct('r', 0.01, 'L', [1.98, 0.5, 0])}, ...
        };
    datasets(dataset_ind).noise_type = 'white';
    datasets(dataset_ind).min_noise = 0.0;
    datasets(dataset_ind).max_noise = 0.1;
    datasets(dataset_ind).noise_level_count = 11;
    datasets(dataset_ind).density_distribution = {{'uniform'}};
    dataset_ind = dataset_ind + 1;

%     allshapes = cat(1,datasets.shapes);
%     if numel(unique(allshapes(:,1))) ~= size(allshapes,1)
%         error('some shape names are duplicates.');
%     end
    
    for d = 1:numel(datasets)
        shapes = datasets(d).shapes;
        noise_type = datasets(d).noise_type;
        min_noise = datasets(d).min_noise;
        max_noise = datasets(d).max_noise;
        noise_level_count = datasets(d).noise_level_count;
        density_distribution = datasets(d).density_distribution;

        for s = 1:size(shapes,1)
            disp(['shape: ', shapes{s,1}])

            for ddist_ind = 1:numel(density_distribution)
                disp(['    density distribution: ',density_distribution{ddist_ind}{1}]);

                for noise_level=linspace(min_noise,max_noise,noise_level_count)

                    disp(['        noise level: ',num2str(noise_level)]);

                    % generate shape file name
                    shape_filename = fullfile(shape_dir,[shapes{s,1},sprintf('%d',round(point_count/1000)),'k']);
                    if noise_level > 0
                        shape_filename = [shape_filename,'_noise_',noise_type,sprintf('_%.2e',noise_level)]; %#ok<AGROW>
                    end
                    if ~strcmp(density_distribution{ddist_ind}{1},'uniform')
                        shape_filename = [shape_filename,'_ddist_',density_distribution{ddist_ind}{1}]; %#ok<AGROW>
                    end

                    % skip if it exists already
                    if exist([shape_filename,'.xyz'],'file') == 2
                        continue;
                        % regenerating them would maybe mean they get differnt point
                        % locations, and ground truth normals, so the current normals
                        % generated by our models would need to be re-generated as well
                        % (which takes a long time)
                    end

                    rng_orig_state = rng(seed);

                    % generate point samples
                    if strcmp(shapes{s,2},'mesh')
                        pcloud = pcloud_from_mesh(point_count, density_distribution{ddist_ind}, shapes{s,3}{:});
                    elseif strcmp(shapes{s,2},'analytic')
                        pcloud = pcloud_analytic(point_count, density_distribution{ddist_ind}, shapes{s,3}{:});
                    else
                        error('Unrecognized shape source');
                    end

                    % add noise
                    if noise_level > 0
                        pcloud = pcloud_add_noise(pcloud, noise_type, noise_level);
                    end

                    rng(rng_orig_state);

                    % save point cloud
                    dlmwrite([shape_filename, '.xyz'], pcloud.points, 'precision', '%.6f', 'delimiter', ' ');
                    dlmwrite([shape_filename, '.normals'], pcloud.normals, 'precision', '%.6f', 'delimiter', ' ');
                    dlmwrite([shape_filename, '.curv'], pcloud.curvatures, 'precision', '%.6f', 'delimiter', ' ');
                    disp(['        generated files: ', shape_filename]);
                end
            end
        end

    end
end
