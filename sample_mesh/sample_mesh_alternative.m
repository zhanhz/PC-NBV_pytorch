function [points, map, normals] = sample_mesh(vertices, faces, n )
% Samples n points on a mesh given by vertices and faces.
% points = the x,y,z positions of sampled points.
% map = for each point the closest vertex on the mesh, for evaluation purpose.

    areas = computeArea(vertices, faces);

%     cum_areas = cumsum(areas);
%     % cum_areas = cum_areas - cum_areas(1);
%     cum_areas = [0;cum_areas ./ cum_areas(end)];

    % Choose face by area:
    faceind = randsample(numel(areas),n,true,areas);
    v = faces(faceind,:);
    va = vertices(v(:,1),:);
    vb = vertices(v(:,2),:);
    vc = vertices(v(:,3),:);

    % Choose position on face:
    rx = rand(n,1);
    ry = rand(n,1);
    ra = (1-sqrt(rx));
    rb = sqrt(rx).*(1-ry);
    rc = sqrt(rx).*ry;
    points = ra.*va + rb.*vb + rc.*vc;

    % Finding the closest vertex on the shape:
    [~,ind] = max([ra,rb,rc],[],2);
    map = v(sub2ind(size(v),1:size(v,1),ind'));

    % Computing vertex normal:
    normals = cross((vb - va)', (vc - va)')';
    normals = normals ./ sqrt(sum(normals.^2,2));

    if any(isnan(normals(:)))
        error('There were undefined normals! Maybe the mesh has degenerate faces.');
    end

end
