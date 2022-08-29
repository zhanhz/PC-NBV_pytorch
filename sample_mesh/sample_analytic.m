function [ points, normals, curvatures ] = sample_analytic( r, L, n )
% Samples points from a smooth analytic surface which is made of a cube
% with rounded corners. By setting cube lengths to 0 you can create a
% cylinder with half a sphere at each end or a shpere.
%
% r = radius of the rounded corners
% L = [Lx Ly Lz] = length of each side of the cube

cube_xy_area = 2 * L(1) * L(2);
cube_xz_area = 2 * L(1) * L(3);
cube_yz_area = 2 * L(2) * L(3);
cube_area = cube_xy_area + cube_xz_area + cube_yz_area;

cylinder_x_area = 2 * pi * r * L(1);
cylinder_y_area = 2 * pi * r * L(2);
cylinder_z_area = 2 * pi * r * L(3);
cylinder_area = cylinder_x_area + cylinder_y_area + cylinder_z_area;

sphere_area = 4 * pi * r * r;

total_area = sphere_area + cylinder_area + cube_area;

points = zeros(n, 3);
normals = zeros(n, 3);
curvatures = zeros(n, 2);

for i=1:n
    section = rand * total_area;
    
    if (section < sphere_area)
        [point, normal, curvature] = sample_sphere(r, L);
    elseif (section < cylinder_area + sphere_area)
        % Sample a point from the cylinders around the edges:
        sub = section - sphere_area;
        if (sub < cylinder_x_area)
            % Sample a point from a cylinder around x axis:
            [point, normal, curvature] = sample_cylinder(r, L(1), L(2), L(3));
        elseif (sub < cylinder_x_area + cylinder_y_area)
            % Sample a point from a cylinder around y axis:
            [pp, nn, curvature] = sample_cylinder(r, L(2), L(1), L(3));
            % rotate point and normal accordingly:
            point = pp([2 1 3]);
            normal = nn([2 1 3]);
        else
            % Sample a point from a cylinder around z axis:
            [pp, nn, curvature] = sample_cylinder(r, L(3), L(2), L(1));
            % rotate point and normal accordingly:
            point = pp([3 2 1]);
            normal = nn([3 2 1]);
        end;
    else
        % Sample a point from the faces of the cube:
        sub = section - sphere_area - cylinder_area;
        if (sub < cube_xy_area)
            % Sample a point from the faces on the XY plane:
            [point, normal, curvature] = sample_cube_faces(r, L(1), L(2), L(3));
        elseif (sub < cube_xy_area + cube_xz_area)
            % Sample a point from the faces on the XZ plane:
            [pp, nn, curvature] = sample_cube_faces(r, L(1), L(3), L(2));
            point = pp([1 3 2]);
            normal = nn([1 3 2]);
        else
            % Sample a point from the faces on the YZ plane:
            [pp, nn, curvature] = sample_cube_faces(r, L(2), L(3), L(1));
            point = pp([3 1 2]);
            normal = nn([3 1 2]);
        end;
    end;
    
    points(i, :) = point;
    normals(i, :) = normal;
    curvatures(i, :) = curvature;
end;



    function [point, normal, curvature] = sample_cube_faces(r, Lx, Ly, Lz)
        % Samples a single point from two faces of a cube which are always on the xy plane.
        x = (rand - 0.5) * Lx;
        y = (rand - 0.5) * Ly;
        z = Lz / 2 + r;
        % The points are split 50/50 between the two faces:
        if (rand < 0.5) 
            z = -z;
        end;
        
        point = [x y z];
        normal = [0 0 sign(z)];
        curvature = [0 0];
    end

    function [point, normal, curvature] = sample_cylinder(r, Lx, Ly, Lz)
        % Sample a single point from a cylinder which revolves around the x
        % axis.
        x = (rand - 0.5) * Lx;
        t = rand * 2 * pi;
        y = r * cos(t);
        z = r * sin(t);
        
        y = y + sign(y) * Ly/2;
        z = z + sign(z) * Lz/2;
        
        point = [x y z];
        normal = [0 cos(t) sin(t)];
        curvature = [r 0];
    end
    
    function [point, normal, curvature] = sample_sphere(r, L)
        % Sample a single point from the sphere at the cube's corners.
        vec = randn(1, 3);
        vec = vec / norm(vec);
        
        point = vec * r + sign(vec) .* L / 2;
        normal = vec;
        curvature = [r r];
    end

end



