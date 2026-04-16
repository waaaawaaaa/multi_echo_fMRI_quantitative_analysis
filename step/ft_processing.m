%朱梦莹 2023.04.21
%做的"基于多回波fMRI成像定量脑功能数据分析"，比对了单回波（echo2）,加权组合（TE加权）
%传统定量拟合（T2*FIT）,基于自监督模型的定量拟合（T2*RELAX）四种时间序列的对比
%分为五步
%1、预处理，包括头动校正以及时间层校正
% 2、生成时间序列
%     echo2：直接从原始数据中提取
%     TE_combined：每一个回波成以TE的权重
%     T2*FIT：用学长给的代码T2Map.m,以及修改论文代码得到的t2starfit111.m
%     T2*RELAX：构造训练集mydataset.py，搭建模型，训练模型main_t2s_train.py，以及应用模型main_t2s_test.py
% 3、生理信息数据的处理
% 4、后处理，包括对解剖像以及功能像的处理
%     解剖结构像：配准、分割
%     功能像：归一化、平滑、GLM分析、T检验     只做fingertapping
% 5、计算评估指标
%     tSNR：用预处理后rest2数据算
%     PSC
%     T检验值
%     tPSC
%     功能对比度
%     tCNR：

%运行1——2步
ft_step1_3;
%3、生理信息数据的处理
physio.m
%4
% 解剖结构像：配准、分割
step3_1
% 功能像处理
step3_2

%5
ROI.py %从模板中提取ROI
STEP4_44 %四种影像计算指标,并保存进.xlsx文件中
tsnr444 %四种影像计算TSNR
plot_tpsc44%画四种影像TPSC
figure_4.py%画四种影像计算小提琴图