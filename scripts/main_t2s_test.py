# 2023.04.08
#使用训练好的模型，生成T2*影像
import os
import torch
import torch.nn as nn
# import torch.optim as optim
# import random
import numpy as np
import nibabel as nib
import scipy.io as scio
import argparse
# from network.Unet import Unet_t2s    #导入模型
# from tensorboardX import SummaryWriter   #画图，与tensorboard一样
# import time

# from torch.utils import data
from torchvision import transforms as T

def load_data_nii(image_path):
    data_in = nib.load(image_path)
    input_sets = data_in.get_fdata()
    Transform = T.ToTensor()
    output_image = Transform(input_sets)  # 把PIL.Image或ndarray从 (H x W x C)形状转换为 (C x H x W) 的tensor

    return output_image
#定义模型
class conv_block(nn.Module):    #做两个卷积
    def __init__(self, ch_in, ch_out):

        super(conv_block, self).__init__()
        self.conv = nn.Sequential(
            nn.Conv2d(ch_in, ch_out, kernel_size=3, padding=1),
            nn.ReLU(),
            nn.Conv2d(ch_out, ch_out, kernel_size=3, padding=1),
            nn.ReLU()
        )

    def forward(self, x):
        x = self.conv(x)
        return x


class up_conv(nn.Module):    #向上卷积
    def __init__(self, ch_in, ch_out):
        super(up_conv, self).__init__()
        self.up = nn.Sequential(
            nn.Upsample(scale_factor=2),
            nn.Conv2d(ch_in, ch_out, kernel_size=3, padding=1),
            nn.ReLU()
        )

    def forward(self, x):
        x = self.up(x)
        return x


class outconv(nn.Module):  #最后不是1×1的卷积吗
    def __init__(self, ch_in, ch_out):
        super(outconv, self).__init__()
        self.conv = nn.Sequential(
            nn.Conv2d(ch_in, ch_out, kernel_size=3, padding=1)
        )

    def forward(self, x):
        x = self.conv(x)
        return x


class Unet(nn.Module):   #Unet结构
    def __init__(self, ch_in, ch_out):
        super(Unet, self).__init__()
        self.Conv1 = conv_block(ch_in=ch_in, ch_out=64)
        self.Conv2 = conv_block(ch_in=64, ch_out=128)
        self.Conv3 = conv_block(ch_in=128, ch_out=256)
        self.Conv4 = conv_block(ch_in=256, ch_out=512)

        self.Maxpool = nn.MaxPool2d(kernel_size=2, stride=2)

        self.up4 = up_conv(ch_in=512, ch_out=256)
        self.up_Conv4 = conv_block(ch_in=512, ch_out=256)

        self.up3 = up_conv(ch_in=256, ch_out=128)
        self.up_Conv3 = conv_block(ch_in=256, ch_out=128)

        self.up2 = up_conv(ch_in=128, ch_out=64)
        self.up_Conv2 = conv_block(ch_in=128, ch_out=64)

        self.Conv11 = outconv(64, ch_out)

    def forward(self, x):
        x1 = self.Conv1(x)

        x2 = self.Maxpool(x1)
        x2 = self.Conv2(x2)

        x3 = self.Maxpool(x2)
        x3 = self.Conv3(x3)

        x4 = self.Maxpool(x3)
        x4 = self.Conv4(x4)

        d4 = self.up4(x4)
        d4 = torch.cat((x3, d4), dim=1)   #按维数拼接，1 横着拼；0 竖着拼
        d4 = self.up_Conv4(d4)

        # d3 = self.up3(x3)
        d3 = self.up3(d4)
        d3 = torch.cat((x2, d3), dim=1)
        d3 = self.up_Conv3(d3)

        d2 = self.up2(d3)
        d2 = torch.cat((x1, d2), dim=1)
        d2 = self.up_Conv2(d2)

        out = self.Conv11(d2)
        return out


class Unet_t2s(nn.Module):
    def __init__(self):
        super(Unet_t2s, self).__init__()
        self.Unet_M0 = Unet(ch_in=3, ch_out=1)
        self.Unet_t2s = Unet(ch_in=3, ch_out=1)

    def forward(self, x, Normtemap):
        M0 = self.Unet_M0(x)
        t2s = self.Unet_t2s(x)
        # x_pred = M0 * torch.exp(Normtemap / t2s)  # for Supervised learning
        x_pred = M0 * torch.exp(Normtemap * t2s) # for AutoEncoder model

        return x_pred, t2s, M0



if __name__ == '__main__':
    os.environ['CUDA_VISIBLE_DEVICES'] = "0"     #指定GPU
    torch.backends.cudnn.benchmark = True   #优化运行效率
    parser = argparse.ArgumentParser()

    # experiment name
    parser.add_argument('--name', type=str, default='experiment')
    parser.add_argument('--data_dir', type=str, default='./dataset_test/')
    parser.add_argument('--GPU_NUM', type=str, default='0')

    # model hyper-parametersps
    parser.add_argument('--INPUT_H', type=int, default=64)
    parser.add_argument('--INPUT_W', type=int, default=64)
    parser.add_argument('--INPUT_D', type=int, default=34)
    parser.add_argument('--INPUT_C', type=int, default=3)
    parser.add_argument('--OUTPUT_C', type=int, default=1)
    parser.add_argument('--LABEL_C', type=int, default=3)
    parser.add_argument('--DATA_C', type=int, default=2)
    parser.add_argument('--FILTERS', type=int, default=64)

    parser.add_argument('--CROP_KEY', type=bool, default=False)
    parser.add_argument('--CROP_SIZE', type=int, default=32)

    # test hyper-parameters
    parser.add_argument('--BATCH_SIZE', type=int, default=1)

    parser.add_argument('--model_path', type=str, default='../models/')
    parser.add_argument('--model_num', type=str, default='226')

    parser.add_argument('--test_dir', type=str, default='')

    parser.add_argument('--tes', type=list, default=[0.014, 0.028, 0.042])
    parser.add_argument('--result_path', type=str,
                        default='/DATA_Inter/zyh/trained_MEEPI/rest_run-1/Unet_echo2/sub-001/')
    parser.add_argument('--result_type', type=str, default='t2s')

    config = parser.parse_args()
    # config.model_num = '95'
    config.name = 'Unet_t2s_AE3'
    config.result_type = 't2s'
    # taskname = 'fingerTapping'
    # fn_all = '/DATA_Temp1/zyh/train_Normed_MEEPI_AR/' + taskname + '/'
    # res_root = '/DATA_Temp1/zyh/trained_AR/' + taskname + '/' + config.name + '/'
    # if not os.path.exists(res_root):
    #     os.mkdir(res_root)
    # config.data_dir = fn_all
    ID = ['001', '002', '003', '004', '005', '006', '007', '010', '011', '013', '015', '016', '017', '018', '019',
          '020', '021', '022', '023', '024', '025', '026', '027', '029', '030', '031', '032']
    # task=['fingerTapping','emotionProcessing','fingerTappingImagined','emotionProcessingImagined']
    task=['rest']
    dataset = ['train_all','val_all']
    # test one folder contains all data
    # config.test_dir = fn_all
    # print(fn_all)
    # test(config)
    #
    # # test batch folders
    # # fn_list = os.listdir(fn_all)[0:9]
    # # fn_list = os.listdir(fn_all)[18:]
    #
    # for fn_sub in fn_list:
    #     dir_sub = os.path.join(fn_all, fn_sub)
    #     result_sub = os.path.join(res_root, fn_sub)
    #     config.test_dir = dir_sub
    #     config.result_path = result_sub
    #     if not os.path.exists(result_sub):
    #         os.mkdir(result_sub)
    #     print(dir_sub)
    #     print(result_sub)
    #     test(config)
    #     Reshape2D(result_sub, res_root, config.result_type, config.INPUT_H, config.INPUT_W, config.INPUT_D)
        # Reshape2D(result_sub, res_root, 'Signals_Pred', config.INPUT_H, config.INPUT_W, config.INPUT_D)
        # Reshape2D(result_sub, res_root, 'M0', config.INPUT_H, config.INPUT_W, config.INPUT_D)

    # -----选择GPU-----#
    # os.environ['CUDA_VISIBLE_DEVICES'] = config.GPU_NUM

    # -----地址-----#
    model_dir = os.path.join(config.model_path, config.name + '/' + '_epoch_' + config.model_num + '.pth')  #载入模型地址
    if not os.path.exists(model_dir):
        print('Model not found, please check you path to model')
        os._exit(0)
    # if not os.path.exists(config.result_path):
    #     os.makedirs(config.result_path)

    # # -----读取数据-----#
    # image_dir='F:/rt-me-fMRI/model/data/val/sub-005_task-emotionProcessing_slice1_time1.nii'
    # image=load_data_nii(image_dir)

    # test_batch = get_loader(config.data_dir, config, crop_key=False, num_workers=1, shuffle=False, mode=config.test_dir)

    # -----模型-----#
    net = Unet_t2s()
    # net = Unet(1, 1)
    # net = CNN(torch.tensor(config.tes))

    if torch.cuda.is_available():
        net.cuda()

    # -----载入模型参数-----#
    torch.load(model_dir)
    net.load_state_dict(torch.load(model_dir))
    print('Model parameters loaded!')

    # Setup device
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    # ********************************************test*****************************************************#
    temap_test = torch.Tensor(config.tes).expand(config.INPUT_H, config.INPUT_W, 3).permute(2, 0, 1)
    # Normtemap_test = temap_test[0, :, :] - temap_test
    Normtemap_test = - temap_test
    Normtemap_test = Normtemap_test.to(device)

    with torch.no_grad():
        # -----读取数据-----#
        for data_file in range(0,len(dataset)):
            for id in range(0,len(ID)):
                file_dir = '../dataset/' +dataset[data_file] +'/sub-' + ID[id] + '_task-fingerTapping_slice1_time1.nii'
                if os.path.exists(file_dir):
                   # image_nii = nib.load(file_dir)
                    print('start sub_:',ID[id])
                    for i in range(0,len(task)):
                    # file_dir = '../dataset/' +dataset[data_file] +'/sun-' + ID[id] + '_task-' + task[i] + '_slice1_time1.nii'
                    # if os.path.exists(file_dir):
                        image_nii = nib.load(file_dir) 
                        affine = image_nii.affine.copy()
                        hdr = image_nii.header.copy()
                        out_image=np.ones((64,64,34,210))
                        for t in range(210):  # 210个时间点，34层
                            for slice in range(34):
                                image_dir='../dataset/' +dataset[data_file] +'/sub-' + ID[id] +'_task-'+task[i] +"_slice"+str(slice+1)+"_time"+str(t+1)+".nii"

                # image_nii = nib.load('F:/rt-me-fMRI/model/data/val/sub-005_task-emotionProcessing_slice1_time1.nii')
                # affine = image_nii.affine.copy()
                # hdr = image_nii.header.copy()

                # image_dir = 'F:/rt-me-fMRI/model/data/val/sub-005_task-emotionProcessing_slice1_time1.nii'
                                image = load_data_nii(image_dir)   #tensor
                                image = image.type(torch.FloatTensor)
                                image=torch.reshape(image,(1,3,64,64))     
                                image = image.to(device)
                                X_pred, t2s, M0 = net(image, Normtemap_test)  # forward
                                OUT_test_t2s = 1 / t2s.permute(0, 2, 3, 1).cpu().detach().numpy()
                                out_image[:, :, slice, t] = np.squeeze(OUT_test_t2s)

                       # new_nii = nib.Nifti1Image(out_image, affine, hdr)
                       # file_name ='../results/sub-' + ID[id] + '_task-' + task[i] + ".nii"
                       # nib.save(new_nii, file_name)
                        # file_name_mat='../t2s/sub-' + ID[id] + '_task-' + task[i] + ".mat"
                        file_name_mat='../t2s/sub-' + ID[id] + '_task-' + "rest_run-2" + ".mat"
                        
                        label_var = {"output": out_image}
                        scio.savemat(file_name_mat, label_var)
                        

