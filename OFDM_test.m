%  // ======================================================================
%  //  Jinan University
%  //  @Author: JiZhou CanyangXiong
%  //  @Last Modified time: 2021-03-05
%  //  @description: 主函数
%  // ======================================================================
clear all
close all
clc
BER_SNR = [];
BER_MC_Sim_total = [];
warning off all
OFDMParameters = InitOFDMParameters();

%% 发射机
OFDMFrame = OFDMBigFrameGenerator(OFDMParameters);

%% 模拟信道
OFDMFrame = filter([1, 0.8, 0.1, 0.05, 0.01, 0.005], 1, OFDMFrame);
SNR = 12;
snr = 10^(SNR / 10);
code_power = norm(OFDMFrame)^2 / (length(OFDMFrame)); %信号的符号功率 =var(passchan_ofdm_symbol)
sigma = sqrt(code_power / (snr * 2)); %sigma如何计算，与当前SNR和信号平均能量有关系
[OFDMFrame_rec, awgn] = addnoise(OFDMFrame, sigma); % use randn 噪声只加了实部

%% 接收机
%把1个大帧拆成20个子帧
OFDMFrame_total = reshape(OFDMFrame_rec, [], 20);

% 译码后的20帧的总bits数(用来算总体误码率）
load('./data/bitsAllFrame.mat')
debitsAllFrame = [];

for cir = 1:20
    OFDMFrame_rec_per = OFDMFrame_total(:, cir);
    [decodedMsg_HD] = OFDMFrameReceiver(OFDMFrame_rec_per, OFDMParameters, cir);
    debitsAllFrame = [debitsAllFrame; decodedMsg_HD];
end

[nErrors_HD, ber_HD] = biterr(bitsAllFrame, debitsAllFrame);
ber_HD

% on = 1时执行一遍

OFDMParameters.on = 1;

%% 发射机
OFDMFrame = OFDMBigFrameGenerator(OFDMParameters);

%% 模拟信道
OFDMFrame = filter([1, 0.8, 0.1, 0.05, 0.01, 0.005], 1, OFDMFrame);
SNR = 12;
snr = 10^(SNR / 10);
code_power = norm(OFDMFrame)^2 / (length(OFDMFrame)); %信号的符号功率 =var(passchan_ofdm_symbol)
sigma = sqrt(code_power / (snr * 2)); %sigma如何计算，与当前SNR和信号平均能量有关系
[OFDMFrame_rec, awgn] = addnoise(OFDMFrame, sigma); % use randn 噪声只加了实部

%% 接收机
%把1个大帧拆成20个子帧
OFDMFrame_total = reshape(OFDMFrame_rec, [], 20);

% // ===========================没有星座图，只有纠后误码率==================================
% 译码后的20帧的总bits数(用来算总体误码率）
load('./data/bitsAllFrame.mat')
debitsAllFrame = [];

for cir = 1:20
    OFDMFrame_rec_per = OFDMFrame_total(:, cir);
    [decodedMsg_HD] = OFDMFrameReceiver(OFDMFrame_rec_per, OFDMParameters, cir);
    debitsAllFrame = [debitsAllFrame; decodedMsg_HD];
end

[nErrors_HD, ber_HD] = biterr(bitsAllFrame, debitsAllFrame);
ber_HD
