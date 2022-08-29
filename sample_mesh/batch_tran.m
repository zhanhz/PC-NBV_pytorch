addpath('curvature');

data_type = 'test'

train_dir = '/home/zhanhz/PC-NBV/data/ShapeNetV1/';
model_list_path = [train_dir, data_type, '/model_list.txt']
model_list = importdata(model_list_path)

[r,c] = size(model_list)
for i = 1:r
    model = model_list(i, 1)
    model_path = [train_dir, data_type, '/', num2str(model), '/model.off']
    points = pcloud_from_mesh(16384, {'uniform'}, model_path)
    save_path = [train_dir, data_type, '/', num2str(model), '/model.mat']
    save(save_path, 'points')
end