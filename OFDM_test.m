%  // ======================================================================
%  //  Jinan University
%  //  @Author: JiZhou CanyangXiong
%  //  @Last Modified time: 2021-03-05
%  //  @description: ������
%  // ======================================================================
clear all
close all
clc
BER_SNR = [];
BER_MC_Sim_total = [];
warning off all
OFDMParameters = InitOFDMParameters();

%% �����
OFDMFrame = OFDMBigFrameGenerator(OFDMParameters);

%% ģ���ŵ�
OFDMFrame = filter([1, 0.8, 0.1, 0.05, 0.01, 0.005], 1, OFDMFrame);
SNR = 12;
snr = 10^(SNR / 10);
code_power = norm(OFDMFrame)^2 / (length(OFDMFrame)); %�źŵķ��Ź��� =var(passchan_ofdm_symbol)
sigma = sqrt(code_power / (snr * 2)); %sigma��μ��㣬�뵱ǰSNR���ź�ƽ�������й�ϵ
[OFDMFrame_rec, awgn] = addnoise(OFDMFrame, sigma); % use randn ����ֻ����ʵ��

%% ���ջ�
%��1����֡���20����֡
OFDMFrame_total = reshape(OFDMFrame_rec, [], 20);

% // ===========================û������ͼ��ֻ�о���������==================================
% ������20֡����bits��(���������������ʣ�
load('bitsAllFrame.mat')
debitsAllFrame = [];

for cir = 1:20
    OFDMFrame_rec_per = OFDMFrame_total(:, cir);
    [decodedMsg_HD] = OFDMFrameReceiver(OFDMFrame_rec_per, OFDMParameters, cir);
    debitsAllFrame = [debitsAllFrame; decodedMsg_HD];
end

[nErrors_HD, ber_HD] = biterr(bitsAllFrame, debitsAllFrame);
ber_HD

OFDMParameters.on = 1;

%% �����
OFDMFrame = OFDMBigFrameGenerator(OFDMParameters);

%% ģ���ŵ�
OFDMFrame = filter([1, 0.8, 0.1, 0.05, 0.01, 0.005], 1, OFDMFrame);
SNR = 12;
snr = 10^(SNR / 10);
code_power = norm(OFDMFrame)^2 / (length(OFDMFrame)); %�źŵķ��Ź��� =var(passchan_ofdm_symbol)
sigma = sqrt(code_power / (snr * 2)); %sigma��μ��㣬�뵱ǰSNR���ź�ƽ�������й�ϵ
[OFDMFrame_rec, awgn] = addnoise(OFDMFrame, sigma); % use randn ����ֻ����ʵ��

%% ���ջ�
%��1����֡���20����֡
OFDMFrame_total = reshape(OFDMFrame_rec, [], 20);

% // ===========================û������ͼ��ֻ�о���������==================================
% ������20֡����bits��(���������������ʣ�
load('bitsAllFrame.mat')
debitsAllFrame = [];

for cir = 1:20
    OFDMFrame_rec_per = OFDMFrame_total(:, cir);
    [decodedMsg_HD] = OFDMFrameReceiver(OFDMFrame_rec_per, OFDMParameters, cir);
    debitsAllFrame = [debitsAllFrame; decodedMsg_HD];
end

[nErrors_HD, ber_HD] = biterr(bitsAllFrame, debitsAllFrame);
ber_HD
%  // ======================================================================

% (1) // ======================================================================
%     ���������ʺ�����ͼ
% number_of_error_all = 0;
% pre_code_errors_all = 0;
%
% for cir = 1:20
%     OFDMFrame_rec_per = OFDMFrame_total(:,cir);
%     [PerQAMtotal,PerQAMError,QAM_re_sum, pre_code_errors,number_of_error] = OFDMFrameReceiver(OFDMFrame_rec_per, OFDMParameters, cir);
%     number_of_error_all = number_of_error_all + number_of_error;
%     pre_code_errors_all = pre_code_errors_all + pre_code_errors;
%     %�ռ�20����֡�ĵ㣬������ͼ, ��Ӧ��ÿ������ͼ���������Ǿ����
%     QAM_re_all(cir,:) = QAM_re_sum;
%     PerQAMError_all(cir,:) = PerQAMError;
%     PerQAMtotal_all(cir,:) = PerQAMtotal;
% end
%
% on = OFDMParameters.on;
% bitNumber = OFDMParameters.bitNumber;
% if on == 0
%     BER_pre_woChow = pre_code_errors_all/(bitNumber*20) %bitNumber��һ��С��֡�ı�������20��С��֡���һ����֡
%     BER_post_woChow = number_of_error_all/(bitNumber*20)
% else
%     load('bitAllocSort.mat');
%     BER_pre_wChow = pre_code_errors_all/(bitNumber*20) %bitNumber��һ��С��֡�ı�������20��С��֡���һ����֡
%     BER_post_wChow = number_of_error_all/(bitNumber*20)
%     PerQAMError_all = sum(PerQAMError_all);
%     PerQAMtotal_all = sum(PerQAMtotal_all);
%     for i = 1:length(bitAllocSort)
%         QAM_re_per_total = QAM_re_all(:,i);
%         QAM_re_per_total = cell2mat(QAM_re_per_total);
%         scatterplot(QAM_re_per_total);
%         %ȡ��ÿ��QAM��Ӧ�Ĵ������ͱ�������
%         errorNum = PerQAMError_all(1,i);
%         totalNum = PerQAMtotal_all(1,i);
%         BER_post = errorNum/totalNum;
%         title(['BER-MC-post = ', num2str(BER_post)  '---NE= ', num2str(errorNum)]);
%     end
% end
%  // ======================================================================
