%画出结果图，TPSC
file_root = 'F:\rt-me-fMRI\';
xls_dir = [file_root 'result_relax_fit'];
excel_tPSC = [xls_dir '\batch_tPSC.xlsx'];

% for i=1:27
%     tPSC_echo2(i,:) = xlsread(excel_tPSC,1,['C' num2str(1+i) ':HD' num2str(1+i)]);
%     tPSC_TEcom(i,:) = xlsread(excel_tPSC,1,['C' num2str(28+i) ':HD' num2str(28+i)]);
%     tPSC_t2starFIT(i,:) = xlsread(excel_tPSC,1,['C' num2str(55+i) ':HD' num2str(55+i)]);
% end
% mean_tPSC_echo2=mean(tPSC_echo2);
% mean_tPSC_TEcom=mean(tPSC_TEcom);
% mean_tPSC_t2starFIT=mean(tPSC_t2starFIT);

i=25;

mean_tPSC_t2s_relax = xlsread(excel_tPSC,1,['C' num2str(1+i) ':HD' num2str(1+i)]);
mean_tPSC_t2starFIT = xlsread(excel_tPSC,1,['C' num2str(28+i) ':HD' num2str(28+i)]);
% mean_tPSC_t2starFIT = xlsread(excel_tPSC,1,['C' num2str(55+i) ':HD' num2str(55+i)]);
% for i=2:209
%     mean_tPSC_t2s_relax(i)=(mean_tPSC_t2s_relax(i-1)+mean_tPSC_t2s_relax(i)+mean_tPSC_t2s_relax(i+1))/3;
% %     mean_tPSC_TEcom(i)=(mean_tPSC_TEcom(i-1)+mean_tPSC_TEcom(i)+mean_tPSC_TEcom(i+1))/3;
%     mean_tPSC_t2starFIT(i)=(mean_tPSC_t2starFIT(i-1)+mean_tPSC_t2starFIT(i)+mean_tPSC_t2starFIT(i+1))/3;
% end
figure(1);
plot(mean_tPSC_t2s_relax,'r')
hold on;
% plot(mean_tPSC_TEcom,'g')
plot(mean_tPSC_t2starFIT,'b')
legend('t2starrelax','t2starFIT');axis([0 210 -1 2])
title('realtime tPSC sub030');