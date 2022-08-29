% n: normal that points to the viewer when viewed from ccw side
% a: area of polygon
function [n,a] = polygonNormal3D(poly)
    if size(poly,2) < 3
        error('Normal not defined for lines or points');
    end

    e = bsxfun(@minus,poly(:,2:end),poly(:,1));
    
    en = cross(e(:,1:end-1),e(:,2:end));
    nlen = sqrt(sum(en.^2,1));
    
    an = sum(en,2); % to compute area
    a = sqrt(sum(an.^2,1))./2;
    
    % use most numerically stable as normal (won't use average because that
    % could be numerically unstable and we assume planar polygons anyway)
    [maxlen,ind] = max(nlen);
    if maxlen < eps('double') * 100
        error('Polygon normal length is below double precision');
    end
    n = en(:,ind) ./ maxlen;
    
    if dot(an,n) < 0
        n = n.*-1;
    end
end
