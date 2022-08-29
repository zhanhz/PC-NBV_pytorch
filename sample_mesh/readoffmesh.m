% [verts,faces,comments] = readoffmesh(filename,nvpairs)
function [verts,faces,comments] = readoffmesh(filename,varargin)
    
    options = struct(...
        'triangulate',true ...
        );
    options = nvpairs2struct(varargin,options);

    fid = fopen(filename,'r');
    if fid < 0
        error(['Cannot open file ''', filename,'''.']);
    end
    
    try
        % read header
        first_token = fscanf(fid,'%s',1);
        if not(any(strcmp(first_token,{'OFF','COFF'})))
            error(['File ''', filename,''' does not appear to be a valid OFF file.']);
        end

        % read remaining lines
        vc = 0;
        fc = 0;
        counts = [];
        nverts = 0;
        nfaces = 0;
        verts = zeros(3,0);
        faces = [];
        comments = cell(1,0);
        linestr = fgetl(fid);
        while ischar(linestr)
            linestr = strtrim(linestr);

            if isempty(linestr)
                % do nothing
            elseif linestr(1) == '#'
                comments{end+1} = linestr(2:end); %#ok<AGROW>
            elseif isempty(counts)
                counts = sscanf(linestr,'%lu',3);
                if numel(counts) ~= 3
                    error(['File ''', filename,''' has errors in the vertex, face and edge count declaration.']);
                end
                nverts = counts(1);
                nfaces = counts(2);
                verts = zeros(3,nverts);
            elseif vc < nverts
                vc = vc+1;
                v = sscanf(linestr,'%f',3);
                if numel(v) ~= 3
                    error(['File ''', filename,''' has errors in the vertex data.']);
                end
                verts(:,vc) = v;
            elseif fc < nfaces
                [fvcount,~,~,nextind] = sscanf(linestr,'%u',1);
                if numel(fvcount) ~= 1
                    error(['File ''', filename,''' has errors in the face data.']);
                end
                if fvcount < 3
                    error(['File ''', filename,''' has faces with less than three vertices.']);
                end
                linestr(1:nextind-1) = [];
                f = sscanf(linestr,'%f',fvcount);
                if size(f,1) ~= fvcount
                    error(['File ''', filename,''' has errors in the face data.']);
                end
                if options.triangulate && fvcount ~= 3
                    
                    polyvertinds = f;
                    poly = verts(:,polyvertinds+1);
                    
                    % rotate polygon to xy plane (with polygon ccw when viewed from positive z)
                    n = polygonNormal3D(poly);
                    
                    axis = cross(n,[0;0;1]);
                    angle = acos(dot(n,[0;0;1]));
                    axislen = sqrt(sum(axis.^2));
                    if axislen > eps('double') * 1000
                        axis = axis ./ axislen;
                        rmat = axisangle2rotmat(axis,angle);
                    else
                        if angle > pi/2
                            % normal is approx. [0;0;-1], rotate 180 deg.
                            % (about the Y-axis in this case)
                            rmat = [-1,0,0 ; 0,1,0; 0,0,-1];
                        else
                            rmat = eye(3);
                        end
                    end
                    
                    poly = rmat * poly;
                    
                    tri = delaunayTriangulation(poly(1:2,:)',[1:size(poly(1:2,:),2);2:size(poly(1:2,:),2),1]');
                    f = polyvertinds(tri.ConnectivityList(tri.isInterior,:)');
%                     if polyiscw
%                         % make triangle the same winding order as the
%                         % polygon (dalaunay outputs ccw triangles)
%                         f = f([1,3,2],:);
%                     end
                    if size(tri.Points,1) ~= size(poly,2)
                        error('Could not triangulate a face. (Is it degenerate?)');
                    end
                    fvcount = 3;
                end
                if fc==0
                    faces = zeros(fvcount,nfaces);
                elseif fvcount ~= size(faces,1)
                    error(['File ''', filename,''': faces with different vertex counts currently not supported.']);
                end
                faces(:,fc+1:fc+size(f,2)) = f;
                
                fc = fc + size(f,2);
                nfaces = nfaces + size(f,2)-1;
            end
            linestr = fgets(fid);
        end
        
    catch err
        fclose(fid);
        rethrow(err);
    end
    
    fclose(fid);
    
    faces = faces + 1; % to matlab indexing
    
    verts = verts';
    faces = faces';
end
