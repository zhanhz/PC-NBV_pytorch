function pcloud = pcloud_add_noise(pcloud, noise_color, noise_strength)

    % Add noise:
    if (noise_strength > 0)
        if strcmp(noise_color,'white')
        %     % uniform error distribution
        %     S.points = S.points + (rand(size(S.points))-1/2) .* (noise_strength * (max(max(S.points,[],1)-min(S.points,[],1))));

            % gaussian error distribution
            % apparently 1/(4.2*sqrt(3)) is the factor to make the std. deviation
            % approximately comparable between brown and white noise (sqrt(3)
            % because this is a deviation for each component separately, muliplying
            % by 1/sqrt(3) converts from vector magnitude std. deviation to vector
            % component std. deviation)
            noise_std = (noise_strength/(4.2*sqrt(3))) * (max(max(pcloud.points,[],1)-min(pcloud.points,[],1)));
            pcloud.points = pcloud.points + normrnd(0,noise_std,size(pcloud.points));

        elseif strcmp(noise_color,'red') || strcmp(noise_color,'brown') || strcmp(noise_color,'brownian')
            maxval = 0.001;
            noise_sample_budget = 500^3; % 500^3 resolution needs about 11-13 gb of memory
            bbox_min = min(pcloud.points,[],1);
            bbox_max = max(pcloud.points,[],1);
            bbox_size = bbox_max - bbox_min;
            noise_res = round((noise_sample_budget .* [...
                bbox_size(1)^2 / (bbox_size(2)*bbox_size(3)); ...
                bbox_size(2)^2 / (bbox_size(1)*bbox_size(3)); ...
                bbox_size(3)^2 / (bbox_size(1)*bbox_size(2))]).^(1/3));
            noise = zeros(size(pcloud.points));
            noise_interpolant = griddedInterpolant({...
                linspace(bbox_min(1),bbox_max(1),noise_res(1)),...
                linspace(bbox_min(2),bbox_max(2),noise_res(2)),...
                linspace(bbox_min(3),bbox_max(3),noise_res(3))},...
                colored_noise(noise_res',-2,0.03),'linear','nearest'); 
            noise(:,1) = noise_interpolant(pcloud.points);
            noise_interpolant.Values = colored_noise(noise_res',-2,0.03);
            noise(:,2) = noise_interpolant(pcloud.points);
            noise_interpolant.Values = colored_noise(noise_res',-2,0.03);
            noise(:,3) = noise_interpolant(pcloud.points);
            noise = noise .* ((noise_strength/maxval) * (max(max(pcloud.points,[],1)-min(pcloud.points,[],1))));

            pcloud.points = pcloud.points + noise;
        else
            error('Unknown noise color.')
        end
    end

end