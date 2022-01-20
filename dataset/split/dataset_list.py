import os
import numpy as np

data_type = 'valid'
class_list_path = '/home/zengrui/IROS/pcn/data/ShapeNetv1/' + data_type + '_class.txt'
gt_dir = "/home/zengrui/IROS/pcn/data/ShapeNetv1/" + data_type
output_path = "data/" + data_type + ".lmdb"
NBV_dir = "/home/zengrui/IROS/pcn/NBV_data/shapenet_33_views"
ex_times = 1
num_scans = 10

with open(os.path.join(class_list_path)) as file:
    class_list = [line.strip() for line in file]

with open('{}_data_list.txt'.format(data_type), 'w') as f:
    ShapeNetv1_dir = '/home/zengrui/IROS/pcn/data/ShapeNetv1/'
    for class_id in class_list:
        model_list = os.listdir(os.path.join(ShapeNetv1_dir, data_type, class_id))
        for model_id in model_list:
            model = os.path.join(class_id, model_id)
            f.write(model + '\n')

