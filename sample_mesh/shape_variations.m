function shape_vars = shape_variations(vanilla_shape_names, point_counts, noise_types, density_types)
    
    shape_vars = struct(...
        'filename',{},...
        'name',{},...
        'noise_level',{},...
        'noise_type',{},...
        'density_type',{});

    % add noisy shape names
    for pci=1:size(point_counts,1)
        
        pc_filename_postfix = [sprintf('%d',round(point_counts{pci}/1000)),'k'];
        pc_name_postfix = '';
        
        for nti=1:size(noise_types,1)

            if noise_types{nti,3} == 0
                noise_filename_postfix = '';
                noise_name_postfix = '';
                noise_iden = true;
            else
                noise_filename_postfix = ['_noise_', noise_types{nti,2}, sprintf('_%.2e',noise_types{nti,3})];
                 noise_name_postfix = ['_', noise_types{nti,1}];
                noise_iden = false;
            end

            for dti=1:size(density_types,1)
                if strcmp(density_types{dti,1},'uniform')
                    density_filename_postfix = '';
                    density_name_postfix = '';
                    density_iden = true;
                else
                    density_filename_postfix = ['_ddist_', density_types{dti,2}];
                    density_name_postfix = ['_', density_types{dti,1}];
                    density_iden = false;
                end

                for j=1:size(vanilla_shape_names,1)
                    if (vanilla_shape_names{j,3} || noise_iden) && ...
                       (vanilla_shape_names{j,4} || density_iden)
                   
                        shape_vars(end+1).filename = [vanilla_shape_names{j,1}, pc_filename_postfix, noise_filename_postfix, density_filename_postfix]; %#ok<AGROW>
                        shape_vars(end).name = [vanilla_shape_names{j,2}, pc_name_postfix, noise_name_postfix, density_name_postfix];
                        shape_vars(end).vanilla_name = vanilla_shape_names{j,2};
                        shape_vars(end).noise_level = noise_types{nti,3};
                        shape_vars(end).noise_type = noise_types{nti,2};
                        shape_vars(end).density_type = density_types{dti,2};
                        shape_vars(end).point_count = point_counts{pci};
                    end
                end
            end
        end
    end
end
