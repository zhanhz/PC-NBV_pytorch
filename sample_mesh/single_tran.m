addpath('curvature');

model_path = '/home/zengrui/IROS/pcn/data/ShapeNetv1/valid/03001627/1e678fabd0622a1119fb4103277a6b93/model.off'
points = pcloud_from_mesh(16384, {'uniform'}, model_path)
save_path = '/home/zengrui/IROS/pcn/data/ShapeNetv1/valid/03001627/1e678fabd0622a1119fb4103277a6b93/model.mat'
save(save_path, 'points')