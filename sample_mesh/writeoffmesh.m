% filename: char array
% verts: 3 x nverts
% faces: ndim x nfaces
function writeoffmesh(filename,verts,faces,comments)
    fid = fopen(filename,'w');
    if fid < 0
        error(['Cannot write to file ''', filename,'''.']);
    end
    
    try
        if size(verts,1) ~= 3
            error('Vertices must be 3-dimensional')
        end

        % write header
        fprintf(fid,'OFF\n');

        % write vertex, face and edge count declaration
        fprintf(fid,'%d %d %d\n',size(verts,2),size(faces,2),0);

        % write comment text
        if nargin >= 4
            for i=1:numel(comments)
                fprintf(fid,'#%s\n',comments{i});
            end
        end

        % write vertices
        for i=1:size(verts,2)
            fprintf(fid,'%d %d %d\n',verts(1,i),verts(2,i),verts(3,i));
        end

        % write faces
        fvcount = size(faces,1);
        formatstr = ['%u ',repmat('%.30g ',1,fvcount),'\n'];
        faces = faces - 1; % to 0-based indexing
        faces = num2cell(faces);
        for i=1:size(faces,2)
            fprintf(fid,formatstr,fvcount,faces{:,i});
        end
    catch err
        fclose(fid);
        rethrow(err);
    end
    
    fclose(fid);
end
