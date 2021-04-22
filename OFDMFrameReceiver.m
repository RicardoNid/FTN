function [decodedMsg_HD] = OFDMFrameReceiver(recvOFDMFrame, cir)
    global On
    global Iteration
    global CPLength
    global DataCarrierPositions
    global PreambleNumber
    global SToPcol
    global FFTSize

    %% 估计信道和FFT
    preamble = recvOFDMFrame(1:PreambleNumber * (FFTSize + CPLength));
    H = ChannelEstimationByPreamble(preamble);
    tap = 20;
    H = smooth(H, tap);
    recvOFDMSignal = recvOFDMFrame(PreambleNumber * (FFTSize + CPLength) + 1:end);
    recovered = FFT(recvOFDMSignal);

    % 使用估计出的信道信息
    for i = 1:SToPcol;
        recovered(:, i) = recovered(:, i) ./ H(DataCarrierPositions);
    end

    % 除对应功率
    if On == 1
        load('./data/power_alloc.mat');

        for i = 1:SToPcol
            recovered(DataCarrierPositions - 2, i) = recovered(DataCarrierPositions - 2, i) ./ sqrt(power_alloc');
        end

    else
        recovered = reshape(recovered, [], 1);
    end

    decodedMsg_HD = QAM2Bits(recovered);

    for iter = 1:Iteration
        decodedMsg_HD = Iterating(decodedMsg_HD, iter, recovered, cir);
    end
