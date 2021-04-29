function [decoded] = OFDMFrameReceiver(recvOFDMFrame)
    global On
    global IsPreamble
    global PowerOn
    global Iteration
    global CPLength
    global DataCarrierPositions
    global PreambleNumber
    global SToPcol
    global FFTSize

    %% 信道估计和修正
    % hardware: 不同于功率分配,信道估计必然是动态的,不能做成半静态
    % 信道估计和修正作用于驻留的FDE
    recvPreambleOFDMSymbols = recvOFDMFrame(1:PreambleNumber * (FFTSize + CPLength)); % 将收到的子帧分为训练序列和信息序列
    recvMsgOFDMSymbols = recvOFDMFrame(PreambleNumber * (FFTSize + CPLength) + 1:end);

    IsPreamble = 1;
    reambleQAMSymbols = FFT(recvPreambleOFDMSymbols);

    IsPreamble = 0;
    FDE = FFT(recvMsgOFDMSymbols); % fft,FDE尺寸224*16

    H = ChannelEstimation(reambleQAMSymbols); % 信道估计,得到(训练序列所占据的)各个子载波上的修正系数,H尺寸255*1

    % 信道均?
    for i = 1:SToPcol;
        FDE(:, i) = FDE(:, i) ./ H(DataCarrierPositions - 1); % ?? 此处的子载波对齐可能有误
    end

    % ORIGINAL!
    % 到这一步,得到FDE

    %% 下面描述迭代通路
    % 将FDE分为两支，一支卸载功率分配之后进入迭代通路，另一支直接驻留在迭代入口，而不是卸载功率分配后，又在迭代通路中加载功率分配
    FDEforIterating = FDE; % 驻留在迭代入口

    PowerOn = 0; % 去功率分配
    FDE = PowerOnOff(FDE);

    decoded = QAM2Bits(FDE); % QAM解映射 -> 解交织 -> 维特比译码

    % ?? FDEforIterating是否要进行归一化
    for iter = 1:Iteration
        decoded = Iterating(decoded, iter, FDEforIterating); % 在接收机中迭代译码,并且,在训练模式下进行比特分配
    end

    % ORIGINAL!!

    % dataQAMSymbols = IteratingBetter(FDE);

    % if On == 1 % 去功率分配
    %     PowerOn = 0;
    %     dataQAMSymbols = PowerOnOff(dataQAMSymbols);
    % end

    % decoded = QAM2Bits(dataQAMSymbols); % QAM解映射 -> 解交织 -> 维特比译码
