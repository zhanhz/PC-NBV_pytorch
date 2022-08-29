function [points, normals, curvatures, map] = sample_mesh(vertices, faces, n, use_curvature, density_dist)
% Samples n points on a mesh given by vertices and faces.
% points = the x,y,z positions of sampled points.
% map = for each point the closest vertex on the mesh, for evaluation purpose.

if (nargin < 4)
    use_curvature = 0;
end

areas = computeArea(vertices, faces);
if strcmp(density_dist{1},'uniform')
    % do nothing
elseif strcmp(density_dist{1},'minmax')
    % linear density falloff from bounding box min to boundng box max
    bbmin = min(vertices,[],1);
    bbmax = max(vertices,[],1);
    bbdiag = sum(bbmax-bbmin,2); % 1-norm, otherwise there would be too much min density and too little max density
    face_centroids = (vertices(faces(:,1),:) + vertices(faces(:,2),:) + vertices(faces(:,3),:)) ./ 3;
    f = sum(face_centroids - bbmin,2) / bbdiag;
    f = exp((1-f) .* log2(density_dist{2}) + f .* log2(density_dist{3}));
    areas = areas .* f;
elseif strcmp(density_dist{1},'minmax_layers')
    bbmin = min(vertices,[],1);
    bbmax = max(vertices,[],1);
    bbdiag = sum(bbmax-bbmin,2); % 1-norm, otherwise there would be too much min density and too little max density
    face_centroids = (vertices(faces(:,1),:) + vertices(faces(:,2),:) + vertices(faces(:,3),:)) ./ 3;
    f = sum(face_centroids - bbmin,2) / bbdiag;
    face_layer_ind = min(density_dist{2},floor(f * density_dist{2})+1);
    layer_density = 2.^(linspace(log2(density_dist{3}),log2(density_dist{4}),density_dist{2}));
    layer_density1 = layer_density(1:2:end);
    layer_density2 = layer_density(2:2:end);
    if numel(layer_density1) > numel(layer_density2)
        layer_density2 = [0,layer_density2];
    end
    layer_density = reshape([layer_density1;layer_density2(end:-1:1)],1,[]);
    layer_density = layer_density(1:density_dist{2});
    areas = areas .* layer_density(face_layer_ind)';
else
    error('Unknown density estimation method.');
end
cum_areas = cumsum(areas);
% cum_areas = cum_areas - cum_areas(1);
cum_areas = [0;cum_areas ./ cum_areas(end)];

if (use_curvature)
    FV.faces = faces;
    FV.vertices = vertices;
    get_derivatives = 0;
%     [PrincipalCurvatures,PrincipalDir1,PrincipalDir2,FaceCMatrix,VertexCMatrix,Cmagnitude]= GetCurvatures( FV ,getderivatives);
    [PrincipalCurvatures]= GetCurvatures( FV ,get_derivatives);
    PrincipalCurvatures = PrincipalCurvatures';
end

points = zeros(n, 3);
map = zeros(n, 1);
normals = zeros(n, 3);
curvatures = zeros(n, 2);

for i=1:n
    % Choose face by area:
    r = rand;
    faceind = binarysearch(cum_areas,r(1));
    v = faces(faceind,:);
    va = vertices(v(1),:);
    vb = vertices(v(2),:);
    vc = vertices(v(3),:);
    
    
    % Choose position on vertex:
    rx = rand;
    ry = rand;
    
    ra = (1-sqrt(rx));
    rb = sqrt(rx)*(1-ry);
    rc = sqrt(rx)*ry;
    
    p = ra*va + rb*vb + rc*vc;
    %p = (1-sqrt(rx))*faces(index1,1) + sqrt(rx)*(1-ry)*faces(index1,2) + sqrt(rx)*ry*faces(index1,3);
    points(i, :) = p;
    
    if (use_curvature)
        % Vertex Curvatures:
        cva = PrincipalCurvatures(v(1), :);
        cvb = PrincipalCurvatures(v(2), :);
        cvc = PrincipalCurvatures(v(3), :);
        
        % These are vectors with two values (k1 and k2):
        cv = ra*cva + rb*cvb + rc*cvc;
        curvatures(i, :) = cv;
    end
    
    % Finding the closest vertex on the shape:
    if (ra > rb && ra > rc)
        map(i, :) = v(1);
    elseif (rb > rc)
        map(i, :) = v(2);
    else
        map(i, :) = v(3);
    end
    
    % Computing vertex normal:
    nn = cross(vb - va, vc - va);
    % normalize normal:
    nn = nn / norm(nn);
%     % orient it such that the most significant value is always positive:
%     if (max(abs(nn)) ~= max(nn))
%         nn = -nn;
%     end
    
    normals(i, :) = nn;
end


end