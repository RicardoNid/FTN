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

% ������20֡����bits��(���������������ʣ�
load('./data/bitsAllFrame.mat')
debitsAllFrame = [];

for cir = 1:20
    OFDMFrame_rec_per = OFDMFrame_total(:, cir);
    [decodedMsg_HD] = OFDMFrameReceiver(OFDMFrame_rec_per, OFDMParameters, cir);
    debitsAllFrame = [debitsAllFrame; decodedMsg_HD];
end

[nErrors_HD, ber_HD] = biterr(bitsAllFrame, debitsAllFrame);
ber_HD

% on = 1ʱִ��һ��

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
load('./data/bitsAllFrame.mat')
debitsAllFrame = [];

for cir = 1:20
    OFDMFrame_rec_per = OFDMFrame_total(:, cir);
    [decodedMsg_HD] = OFDMFrameReceiver(OFDMFrame_rec_per, OFDMParameters, cir);
    debitsAllFrame = [debitsAllFrame; decodedMsg_HD];
end

[nErrors_HD, ber_HD] = biterr(bitsAllFrame, debitsAllFrame);
ber_HD
