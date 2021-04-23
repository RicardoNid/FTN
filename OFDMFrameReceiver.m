function [decoded] = OFDMFrameReceiver(recvOFDMFrame)
    global On
    global Iteration
    global CPLength
    global DataCarrierPositions
    global PreambleNumber
    global SToPcol
    global FFTSize

    %% 估计信道和FFT
    preamble = recvOFDMFrame(1:PreambleNumber * (FFTSize + CPLength)); % 将收到的子帧分为训练序列和信息序列
    message = recvOFDMFrame(PreambleNumber * (FFTSize + CPLength) + 1:end);

    H = ChannelEstimationByPreamble(preamble); % 信道估计,得到(训练序列所占据的)各个子载波上的修正系数,H尺寸255*1
    tap = 20;
    H = smooth(H, tap); % 对修正系数做抽头数为20的滑动平均

    FDE = FFT(message); % fft,FDE尺寸224*16

    % 使用估计出的信道信息
    for i = 1:SToPcol;
        FDE(:, i) = FDE(:, i) ./ H(DataCarrierPositions - 1); % ?? 此处的子载波对齐可能有误
    end

    % 将FDE分为两支，一支去除功率分配之后进行解映射，另一支直接送入迭代通路，而不是去除功率分配后，又在迭代通路中加载功率分配
    FDEforIterating = FDE;

    if On == 1 % 工作时,根据训练结果,每个子载波分配相应功率
        load('./data/power_alloc.mat'); % 功率分配,训练模式后接收机反馈的信息之一,power_alloc尺寸1*224

        for i = 1:SToPcol
            FDE(DataCarrierPositions - 2, i) = FDE(DataCarrierPositions - 2, i) ./ sqrt(power_alloc'); % 除去功率分配,FDE尺寸224*16
        end

    end

    decoded = QAM2Bits(FDE); % QAM解映射 -> 解交织 -> 维特比译码

    % ?? FDEforIterating是否要进行归一化
    for iter = 1:Iteration
        decoded = Iterating(decoded, iter, FDEforIterating); % 在接收机中迭代译码,并且,在训练模式下进行比特分配
    end
