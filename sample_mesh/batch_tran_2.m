addpath('curvature');

train_dir = '/home/zhanhz/PC-NBV/data/ShapeNetV1/';
subdir  = dir( maindir );
    
for i = 1 : length( subdir )
    if( isequal( subdir( i ).name, '.' )||...
        isequal( subdir( i ).name, '..')||...
        ~subdir( i ).isdir)               % 如果不是目录则跳过
        continue;
    end
    
    modeldir = dir(fullfile( maindir, subdir( i ).name))
   
    for j = 1 : length( modeldir )
        if( isequal( modeldir( j ).name, '.' )||...
            isequal( modeldir( j ).name, '..')||...
            ~modeldir( j ).isdir)             
            continue;
        end
    
        subdirpath = fullfile( maindir, subdir( i ).name, modeldir( j ).name, '*.off' );

        model_list = dir(subdirpath)
        for k = 1 : length( model_list )
            model_path = fullfile( maindir, subdir( i ).name, modeldir( j ).name, model_list( k ).name)
            points = pcloud_from_mesh(16384, {'uniform'}, model_path)
            save_path = model_path
            save_path = strrep(save_path, 'off', 'mat')
            save(save_path, 'points')
        end
    end
    

end