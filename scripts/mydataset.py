# 2023.04.08
#构造数据集，我的数据文件是在每个受试者func文件下，取经过预处理后，即以ar开头的文件
#我将他们读入，按每一层，给他写成3回波的形式，64*64*3，
#随机分为8:2到训练集和测试集
import os
import numpy as np
import nibabel as nib
import random
from joblib import parallel


ID=['001','002','003','004','005','006','007','010','011','013','015','016','017','018','019','020','021','022','023','024','025','026','027','029','030','031','032']
data_root = 'F:/rt-me-fMRI/'
save_dir_train = data_root+'model/data/train/'
save_dir_val = data_root+'model/data/val/'

# random_index = random.sample(range(0, 27), 5)  #分为8:2，则27*0.2,接近5
random_index = [24, 18, 15, 6, 4]   #为了让每一次分训练的测试数据一致
# os.makedirs(save_dir_train)
# os.makedirs(save_dir_val)
parallel(n_jobs=-1)
for id in range(0,len(ID)):
    data_dir = data_root+'sub-'+ID[id] + '/func'  # 输入文件路径
# data_dir = 'D:/rt-me-fMRI/sub-001/func'   #输入文件路径
# save_dir_train = 'D:/rt-me-fMRI/model/data/train'
# save_dir_val = 'D:/rt-me-fMRI/model/data/val'
# os.makedirs(save_dir_train)
# os.makedirs(save_dir_val)
# image_paths =  os.listdir(data_dir)[0:3]   #找到路径下的所有文件,并取前3个，以ar开头的文件在前面几个
    image_paths=[]
    for image_path in os.listdir(data_dir):
        if os.path.basename(image_path)[0:5] == 'arsub':  #找到前五个字母为arsub的文件
            image_paths.append(image_path)

    image_paths.sort(reverse=True)
    # data=np.ones((64,64,2380*len(image_paths),3))   #输入的FMRI数据为64*64*34*210
    for i in range(0,len(image_paths)//3):
        path_echo3 = os.path.join(data_dir, image_paths[3 * i]) # 写成全路径格式
        path_echo2 = os.path.join(data_dir, image_paths[3 * i + 1])
        path_echo1 = os.path.join(data_dir, image_paths[3 * i + 2])

        image_echo1 = nib.load(path_echo1)  # 读入nii影像
        image_echo2 = nib.load(path_echo2)
        image_echo3 = nib.load(path_echo3)
        affine=image_echo1.affine.copy()
        hdr=image_echo1.header.copy()

        temp_echo1 = image_echo1.get_fdata()  # 读入nii影像
        temp_echo2 = image_echo2.get_fdata()
        temp_echo3 = image_echo3.get_fdata()

        for t in range(210):    #210个时间点，34层
            for slice in range(34):
                data=np.ones((64,64,3))
                # temp_echo1 = nib.load(path_echo1).get_fdata()   #读入nii影像
                # temp_echo2 = nib.load(path_echo2).get_fdata()
                # temp_echo3 = nib.load(path_echo3).get_fdata()
                data[:, :, 0] = temp_echo1[:, :, slice, t]
                data[:, :, 1] = temp_echo2[:, :, slice, t]
                data[:, :, 2] = temp_echo3[:, :, slice, t]
                max_data = np.max(data)
                if max_data==0:
                    data_normalized = data
                else:
                    data_normalized = data/max_data
                new_nii = nib.Nifti1Image(data_normalized,affine,hdr)
                file_name='sub-'+ID[id] +'_' + image_paths[3 * i].split("_")[1]+"_slice"+str(slice+1)+"_time"+str(t+1)+".nii"
                if id in random_index:
                    nib.save(new_nii,os.path.join(save_dir_val, file_name))
                else:
                    nib.save(new_nii, os.path.join(save_dir_train, file_name))


    # for echoes in range(0,2):
    #     temp= nib.load(path_echoeses).get_fdata()   #读入nii影像
    #     (nx,ny,ns,nt)=temp.shape
    #     for t in range(nt):
    #         for slice in range(ns):
    #             data[:,:,echoes,nt*i+ns*t+slice]=temp[:,:,slice,t]
        # temp_data=temp.reshape(nx,ny,ns*nt)
        # data[:,:,7140*i:7140*(i+1),echoes]=temp_data


# label=np.ones([2380*len(image_paths),1])
# train_data = data[:,:,0:5712,:]
