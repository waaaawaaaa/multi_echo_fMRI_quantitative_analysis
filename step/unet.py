# 1.导入包
import numpy as np
import nibabel as nib
import os
from collections import Counter

# 2.读入文件
roiIndex = 57 # 设置需要保存哪个区域（可在网上查到每个ROI对应的编号）
basePath = 'D:/Download/matlab2022/toolbox/DPABI/Templates' # 读取模板文件夹的路
outputPath = 'D:\proprecess\sub-001\ROI' # 保存文件的
atlasName = "aal.nii" # 模板文件名
atlasFile = os.path.join(basePath, atlasName)

atlas_nii = nib.load(atlasFile)      #读入模板
atlas_arr = atlas_nii.get_fdata()

# 3.设置
mask_arr = atlas_arr.copy()
mask_arr[atlas_arr != roiIndex] = 0        #处于ROI置1，不处于置0
mask_arr[atlas_arr == roiIndex] = 1
mask_affine = atlas_nii.affine.copy()       #仿射矩阵

mask_hrd = atlas_nii.header.copy()          #头文件
mask_hrd["cal_max"] = 1

mask_nii = nib.Nifti1Image(mask_arr, mask_affine, mask_hrd)
nib.save(mask_nii,os.path.join(outputPath, "roi_" + str(roiIndex) + ".nii"))