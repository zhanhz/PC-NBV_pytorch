function R = axisangle2rotmat(v,theta)
    % Compute rotation matrices
    cth = cos(theta);
    sth = sin(theta);
    vth = (1 - cth);

    % % Preallocate input vectors
    % vx = zeros(1,1,numInputs,'like',axang);
    % vy = vx;
    % vz = vx;
    vx = zeros(1,1,size(v,2));
    vy = vx;
    vz = vx;

    % Shape input vectors in depth dimension
    vx(1,1,:) = v(1,:);
    vy(1,1,:) = v(2,:);
    vz(1,1,:) = v(3,:);

    % Explicitly specify concatenation dimension
    tempR = cat(1, vx.*vx.*vth+cth,     vy.*vx.*vth-vz.*sth, vz.*vx.*vth+vy.*sth, ...
                   vx.*vy.*vth+vz.*sth, vy.*vy.*vth+cth,     vz.*vy.*vth-vx.*sth, ...
                   vx.*vz.*vth-vy.*sth, vy.*vz.*vth+vx.*sth, vz.*vz.*vth+cth);

    R = reshape(tempR, [3, 3, length(vx)]);
    R = permute(R, [2 1 3]);
end
