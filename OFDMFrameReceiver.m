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
    preamble = recvOFDMFrame(1:PreambleNumber * (FFTSize + CPLength)); % 将收到的子帧分为训练序列和信息序列
    message = recvOFDMFrame(PreambleNumber * (FFTSize + CPLength) + 1:end);

    H = ChannelEstimationByPreamble(preamble); % 信道估计,得到(训练序列所占据的)各个子载波上的修正系数,H尺寸255*1
    tap = 20;
    H = smooth(H, tap); % 对修正系数做span为20的滑动平均

    IsPreamble = 0;
    FDE = FFT(message); % fft,FDE尺寸224*16

    % 使用估计出的信道信息
    for i = 1:SToPcol;
        FDE(:, i) = FDE(:, i) ./ H(DataCarrierPositions - 1); % ?? 此处的子载波对齐可能有误
    end

    % 到这一步,驻留的FDE已经确定

    %% 下面描述迭代通路
    % 将FDE分为两支，一支去除功率分配之后进入迭代通路，另一支直接驻留在迭代入口，而不是去除功率分配后，又在迭代通路中加载功率分配
    FDEforIterating = FDE; % 驻留在迭代入口

    if On == 1 % 工作时,根据训练结果,每个子载波分配相应功率
        PowerOn = 0;
        FDE = PowerOnOff(FDE);
    end

    decoded = QAM2Bits(FDE); % QAM解映射 -> 解交织 -> 维特比译码

    % ?? FDEforIterating是否要进行归一化
    for iter = 1:Iteration
        decoded = Iterating(decoded, iter, FDEforIterating); % 在接收机中迭代译码,并且,在训练模式下进行比特分配
    end
