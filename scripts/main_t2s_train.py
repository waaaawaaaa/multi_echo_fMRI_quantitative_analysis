# 2023.04.08
#完成模型的训练
import os
import torch
import torch.nn as nn
import torch.optim as optim
# import random
import numpy as np
import nibabel as nib
# import scipy.io as scio
import argparse
# from network.Unet import Unet_t2s    #导入模型
from tensorboardX import SummaryWriter   #画图，与tensorboard一样
import time

from torch.utils import data
from torchvision import transforms as T

##----------为了读入数据集——————————
def load_data_nii(image_path):
    data_in = nib.load(image_path)
    input_sets = data_in.get_fdata()
    label_sets = np.zeros((1, 1), dtype=np.float32)

    return input_sets, label_sets


class ImageFolder(data.Dataset):

    def __init__(self, root):
        """Initialize image paths and preprocessing module."""
        # self.config = config
        self.image_dir = root
        self.image_paths = os.listdir(self.image_dir)

    def __getitem__(self, idx):
        """Read an image from a file and preprocesses it and returns."""
        img_name = self.image_paths[idx]
        image_path = os.path.join(self.image_dir,img_name)
        image, label = load_data_nii(image_path)   #返回图像与标签，这里标签不起作用

        # -----To Tensor-----
        Transform = T.ToTensor()
        image = Transform(image)   #把PIL.Image或ndarray从 (H x W x C)形状转换为 (C x H x W) 的tensor
        label = Transform(label)

        return image, label

    def __len__(self):
        """Return the total number of this dataset"""
        return len(self.image_paths)



def get_loader(image_path, config, num_workers, shuffle=True):
    """Builds and returns Dataloader"""
    dataset = ImageFolder(root=image_path)    #读入数据集
    data_loader = data.DataLoader(dataset=dataset,           #将数据集转换为训练模型所用的类型
                                  batch_size=config.BATCH_SIZE,
                                  shuffle=shuffle,
                                  num_workers=num_workers,   #num_workers=0指单线程读入，1，多线程
                                  pin_memory=True)    #batch_size几个图像一起取；shuffle图像选取顺序打乱，pin_memory舍去最后不足batch_size的图
    return data_loader

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
    data_root = '../dataset/'
    data_dir_train = data_root+'train'
    data_dir_val = data_root + 'val'
    parse = argparse.ArgumentParser()
    # experiment name
    # parse.add_argument('--name', type=str, default='experiment')
    parse.add_argument('--experiment_path', type=str, default='')
    # parse.add_argument('--data_dir', type=str, default='./dataset_norm_1')
    parse.add_argument('--GPU_NUM', type=str, default='0')

    # model hyper-parameters
    parse.add_argument('--INPUT_H', type=int, default=64)
    parse.add_argument('--INPUT_W', type=int, default=64)

    # parse.add_argument('--CROP_KEY', type=bool, default=True)
    # parse.add_argument('--CROP_SIZE', type=int, default=32)

    # training hyper-parameters
    parse.add_argument('--num_epochs', type=int, default=500)
    parse.add_argument('--BATCH_SIZE', type=int, default=256)
    # parse.add_argument('--NUM_WORKERS', type=int, default=1)
    parse.add_argument('--lr', type=float, default=1e-4)
    parse.add_argument('--lr_update', type=float, default=40000)
    parse.add_argument('--beta1', type=float, default=0.9)
    parse.add_argument('--beta2', type=float, default=0.999)
    parse.add_argument('--regular', type=float, default=0.001)
    parse.add_argument('--step', type=int, default=500)
    parse.add_argument('--model_save_start', type=int, default=1)
    parse.add_argument('--model_save_step', type=int, default=1)

    # misc
    # parse.add_argument('--mode', type=str, default='train')
    parse.add_argument('--model_path', type=str, default='../models')
    parse.add_argument('--result_path', type=str, default='../results')

    parse.add_argument('--tes', type=list, default=[0.014, 0.028, 0.042])

    config = parse.parse_args()

    config.name = 'Unet_t2s_AE3'
    # config.BATCH_SIZE=256
    # config.CROP_SIZE=32
    model_path=config.model_path
    lr = config.lr
    #导入数据
    train_batch = get_loader(data_dir_train, config, num_workers=0, shuffle=True)
    val_batch = get_loader(data_dir_val, config, num_workers=0, shuffle=True)   #长度会等于总数量/
    # dataset_train = ImageFolder(data_dir_train)    #读入数据集
    # dataset_val = ImageFolder(data_dir_val,config)

    # -----模型-----
    net = Unet_t2s()

    # -----损失函数-----
    criterion = nn.MSELoss()

    if torch.cuda.is_available():     #GPU是否可用
        net.cuda()   #将网络以及优化器传入GPU
        criterion.cuda()

    # -----优化器-----
    optimizer = optim.Adam(net.parameters(), lr=config.lr, betas=(config.beta1, config.beta2))

    # -----Setup device-----
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

    # -----Tensorboard-----
    # Writer_train = SummaryWriter(os.path.join(os.path.join(config.experiment_path, 'tensorboard'), 'train'))  #输入文件夹名称
    # Writer_val = SummaryWriter(os.path.join(os.path.join(config.experiment_path, 'tensorboard'), 'val'))
    Writer_train = SummaryWriter("logs_train")  #输入文件夹名称
    Writer_val = SummaryWriter("logs_val")
    # -----csv表-----
    # f = open(os.path.join(config.experiment_path, 'result.csv'), 'a', encoding='utf-8', newline='')
    # wr = csv.writer(f)
    # wr.writerow(['train loss', 'val loss', 'val nmse', 'lr', 'total_iters', 'epochs'])


    temap = torch.Tensor(config.tes).expand(config.INPUT_H, config.INPUT_W, 3).permute(2, 0, 1)
    Normtemap = - temap

    Normtemap = Normtemap.to(device)

    # if config.mode == 'train':
    time2 = time.perf_counter()
    print("......Start Training......")
    total_iters = 0
    for epoch in range(1, config.num_epochs + 1):
        print("Epoch: ", epoch)
        # net = net.train()
        train_loss = 0
        train_length = 0
        val_loss = 0
        # val_nmse = 0
        val_length = 0

        # ******************************train******************************
        for i, (image, label) in enumerate(train_batch):

            images = image.type(torch.FloatTensor)
            images = images.to(device)
            # print("shape of images:",images.shape)
            # GT = GT.type(torch.FloatTensor)
            # GT = GT.to(device)

            optimizer.zero_grad()  # clear grad

            x_pred, t2s, M0 = net(images, Normtemap)
            # t2s = net(images)

            loss_l2 = criterion(images, x_pred)
            # loss_l2 = criterion(GT, t2s)
            loss = loss_l2
            train_loss += loss.item()

            loss.backward()  # backward
            optimizer.step()  # update

            train_length += image.size(0)
            total_iters += 1

            # learning rate decay
            if (total_iters % config.lr_update) == 0:
                for param_group in optimizer.param_groups:
                    param_group['lr'] = param_group['lr'] * 0.8

                lr = optimizer.param_groups[0]['lr']

            # if total_iters % config.step == 0:
            #     lr = optimizer.param_groups[0]['lr']
        Writer_train.add_scalar('data/loss', train_loss / train_length, epoch)  # 标题，x轴，y轴
        # ******************************val******************************
        with torch.no_grad():  # 只需要查看网络状况，不需要反向传播时可使用此命令提高性能
            for i, (images_val, label_val) in enumerate(val_batch):
                images_val = images_val.type(torch.FloatTensor)
                images_val = images_val.to(device)
                # GT_val = GT_val.type(torch.FloatTensor)
                # GT_val = GT_val.to(device)

                x_pred_val, t2s_val, M0_val = net(images_val, Normtemap)  # net.forward(x, config.tes)
                # t2s_val = net(images_val)

                loss_l1_val = criterion(images_val, x_pred_val)
                # loss_l1_val = criterion(GT_val, t2s_val)
                loss_val = loss_l1_val

                val_loss += loss_val.item()
                val_length += images_val.size(0)

        # Print the log info
        time1 = time.perf_counter()
        temp_time = time1 - time2
        print(
            "Epoch [%d/%d], Total iters [%d], Train loss: %.8f, Val loss: %.8f, lr: %.5f, time: %.3f" % (
                epoch, config.num_epochs, total_iters,
                train_loss / train_length, val_loss / val_length, lr, temp_time
            ))

        time2 = time.perf_counter()
        # Writer_train.add_scalar('data/loss', train_loss / train_length, epoch)  #标题，x轴，y轴
        Writer_val.add_scalar('data/loss', val_loss / val_length, epoch)
        # wr.writerow([train_loss / train_length, val_loss / val_length, lr, total_iters, epoch])

            # train_loss = 0
            # train_length = 0
            # val_loss = 0
            # val_length = 0

                    # # ******************************test brain******************************
                    # for i, (brain_images, _) in enumerate(brain_batch):
                    #     brain_images = brain_images.type(torch.FloatTensor)
                    #     brain_images = brain_images.to(device)
                    #     x_pred_brain, t2s_brain, M0_brain = net(brain_images, Normtemap_test)
                    #     # t2s_brain = net(brain_images)
                    #
                    #     # save result in fold
                    #     # save_dir = os.path.join(save_inter_result, 'inter_X_' + str(total_iters) + '_brain')
                    #     # save_torch_result_3d(x_pred_brain., save_dir, format='png', cmap='jet', norm=False,
                    #     #                      crange=[0, 2])
                    #
                    #     save_dir = os.path.join(save_inter_result, 'inter_t2s_' + str(total_iters) + '_brain')
                    #     save_torch_result(1 / t2s_brain, save_dir, format='png', cmap='jet', norm=False,
                    #                       crange=[0, 0.2])
        # -----save model-----
        if (epoch) % config.model_save_step == 0 and epoch > config.model_save_start:   #相当于每次迭代都保存了
            if not os.path.exists(model_path):
                os.mkdir(model_path)
            torch.save(net.state_dict(), model_path + '/' + config.name + '/' + '_epoch_' + str(epoch) + '.pth')

    # f.close()
    Writer_train.close()
    Writer_val.close()