function pcloud = pcloud_analytic(np, density_dist, type, params)
% pcloud_anaytic creates a point cloud from an analytic surface
%
% type = type of analytic surface
% np = number of points to sample
% params = analytic surface parameters

    if not(strcmp(density_dist{1},'uniform'))
        error('Sample density distributions other than uniform not supported.');
    end

    pcloud = struct;
    
    if strcmp(type, 'roundedcube')
        [pcloud.points, pcloud.normals, pcloud.curvatures] = sample_analytic(params.r, params.L, np);
    else
        error(['Unsupported analytic surface: ',type])
    end
end
