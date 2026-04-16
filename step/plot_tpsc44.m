%画出结果图，TPSC
file_root = 'F:\rt-me-fMRI\';
xls_dir = [file_root 'result_44'];
excel_tPSC = [xls_dir '\batch_tPSC.xlsx'];

% for i=1:27
%     tPSC_echo2(i,:) = xlsread(excel_tPSC,1,['C' num2str(1+i) ':HD' num2str(1+i)]);
%     tPSC_TEcom(i,:) = xlsread(excel_tPSC,1,['C' num2str(28+i) ':HD' num2str(28+i)]);
%     tPSC_t2starFIT(i,:) = xlsread(excel_tPSC,1,['C' num2str(55+i) ':HD' num2str(55+i)]);
%     tPSC_t2s_relax(i,:) = xlsread(excel_tPSC,1,['C' num2str(82+i) ':HD' num2str(82+i)]);
% end
% mean_tPSC_echo2=mean(tPSC_echo2);
% mean_tPSC_TEcom=mean(tPSC_TEcom);
% mean_tPSC_t2starFIT=mean(tPSC_t2starFIT);
% mean_tPSC_t2s_relax = mean(tPSC_t2s_relax);

i=25;

mean_tPSC_echo2 = xlsread(excel_tPSC,1,['C' num2str(1+i) ':HD' num2str(1+i)]);
mean_tPSC_TEcom = xlsread(excel_tPSC,1,['C' num2str(28+i) ':HD' num2str(28+i)]);
mean_tPSC_t2starFIT = xlsread(excel_tPSC,1,['C' num2str(55+i) ':HD' num2str(55+i)]);
mean_tPSC_t2s_relax = xlsread(excel_tPSC,1,['C' num2str(82+i) ':HD' num2str(82+i)]);
mean_tPSC_echo2(1:2)=[0,0];
mean_tPSC_TEcom(1:2)=[0,0];
mean_tPSC_t2starFIT(1:2)=[0,0];
mean_tPSC_t2s_relax(1:2)=[0,0];

for i=2:209  %平滑
    mean_tPSC_echo2(i)=(mean_tPSC_echo2(i-1)+mean_tPSC_echo2(i)+mean_tPSC_echo2(i+1))/3;
    mean_tPSC_TEcom(i)=(mean_tPSC_TEcom(i-1)+mean_tPSC_TEcom(i)+mean_tPSC_TEcom(i+1))/3;
    mean_tPSC_t2starFIT(i)=(mean_tPSC_t2starFIT(i-1)+mean_tPSC_t2starFIT(i)+mean_tPSC_t2starFIT(i+1))/3;
    mean_tPSC_t2s_relax(i)=(mean_tPSC_t2s_relax(i-1)+mean_tPSC_t2s_relax(i)+mean_tPSC_t2s_relax(i+1))/3;
end
figure(1);
plot(mean_tPSC_echo2,'r')
hold on;
plot(mean_tPSC_TEcom,'g')
plot(mean_tPSC_t2starFIT,'b')
plot(mean_tPSC_t2s_relax,'m')
legend('回波2', 'TE加权组合', 'T2*FIT', 'T2*RELAX');axis([0 210 -1 2])
title('时间信号变化百分比');