import os
import random

import numpy as np
import torch
from torch._C import dtype
import torch.utils.data as Data
import scipy.io as sio

import sys
sys.path.append('.')
sys.path.append('..')
from utils import resample_pcd


class ShapeNet(Data.Dataset):
    def __init__(self, NBV_dir, gt_dir, num_input=512, num_gt=16384, split='train', num_scans=10, ex_times=1):
        self.NBV_dir = NBV_dir
        self.gt_dir = gt_dir
        self.ex_times = ex_times
        self.num_input = num_input
        self.num_gt = num_gt
        self.num_scans = num_scans

        with open('dataset/split/{}_data_list.txt'.format(split), 'r') as f:
            filenames = [line.strip() for line in f]
        
        self.metadata = list()
        for filename in filenames:
            model = filename.split('/')
            for ex_index in range(self.ex_times):
                for scan_index in range(self.num_scans):
                    gt_pc = os.path.join(self.gt_dir, split, model[0], model[1], 'model.mat')
                    view_state = os.path.join(self.NBV_dir, model[1], str(ex_index), str(scan_index) + "_viewstate.npy")
                    accumulate_pointcloud = os.path.join(self.NBV_dir, model[1], str(ex_index), str(scan_index) + "_acc_pc.npy")
                    target_value = os.path.join(self.NBV_dir, model[1], str(ex_index), str(scan_index) + "_target_value.npy")
                    self.metadata.append((accumulate_pointcloud, gt_pc, view_state, target_value))

    def __getitem__(self, index):
        acp_p, gt_pc_p, vs_p, tv_p = self.metadata[index]
        gt_pt = sio.loadmat(gt_pc_p)
        gt_pc = np.array(gt_pt['points'])
        vs = np.load(vs_p).astype(np.float32)
        acp = np.load(acp_p)
        tv = np.load(tv_p).astype(np.float32).reshape(-1)

        acp = resample_pcd(acp, self.num_input).astype(np.float32)
        gt_pc = resample_pcd(gt_pc, self.num_gt).astype(np.float32)

        accumulate_pointcloud = torch.from_numpy(acp)
        gt_point_cloud = torch.from_numpy(gt_pc)
        view_states = torch.from_numpy(vs)
        target_value = torch.from_numpy(tv)

        return accumulate_pointcloud, gt_point_cloud, view_states, target_value

    def __len__(self):
        return len(self.metadata)


if __name__ == '__main__':
    GT_ROOT = "/home/zengrui/IROS/pcn/data/ShapeNetv1/"
    NBV_ROOT = "/home/zengrui/IROS/pcn/NBV_data/shapenet_33_views"

    train_dataset = ShapeNet(NBV_dir=NBV_ROOT, gt_dir=GT_ROOT, split='train')
    val_dataset = ShapeNet(NBV_dir=NBV_ROOT, gt_dir=GT_ROOT, split='valid')
    test_dataset = ShapeNet(NBV_dir=NBV_ROOT, gt_dir=GT_ROOT, split='test')
    print("\033[33mTraining dataset\033[0m has {} pair of partial and ground truth point clouds".format(len(train_dataset)))
    print("\033[33mValidation dataset\033[0m has {} pair of partial and ground truth point clouds".format(len(val_dataset)))
    print("\033[33mTesting dataset\033[0m has {} pair of partial and ground truth point clouds".format(len(test_dataset)))

    # shape
    accumulate_pointcloud, gt_point_cloud, view_states, target_value = train_dataset[random.randint(0, len(train_dataset))]
    print("accumulate_pointcloud shape: {} ".format(accumulate_pointcloud.shape))
    print("gt_point_cloud has shape: {}".format(gt_point_cloud.shape))
    print("view_states has shape: {}".format(view_states.shape))
    print("target_value has shape: {}".format(target_value.shape))
