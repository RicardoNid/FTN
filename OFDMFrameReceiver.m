%  // ======================================================================
%  //  Jinan University
%  //  @Author: JiZhou CanyangXiong
%  //  @Last Modified time: 2021-03-05
%  //  @description: 接收端DSP
%  // ======================================================================

% (4) // =====================带有误码率的输出=====================================
% function  [PerQAMtotal,PerQAMError,QAM_re_sum,pre_code_errors,number_of_error] = OFDMFrameReceiver(recvOFDMFrame, OFDMParameters, cir)
%  // =====================不带误码率的输出=====================================
function [decodedMsg_HD] = OFDMFrameReceiver(recvOFDMFrame, OFDMParameters, cir)
    on = OFDMParameters.on;
    global On
    global Iteration
    CPLength = OFDMParameters.CPLength;
    DataCarrierPositions = OFDMParameters.DataCarrierPositions;
    preambleNumber = OFDMParameters.PreambleNumber;
    SToPcol = OFDMParameters.SToPcol;
    FFTSize = OFDMParameters.FFTSize;
    global tblen
    global RmsAlloc

    %% 估计信道和FFT
    preamble = recvOFDMFrame(1:preambleNumber * (FFTSize + CPLength));
    H = ChannelEstimationByPreamble(preamble, OFDMParameters);
    tap = 20;
    H = smooth(H, tap);
    recvOFDMSignal = recvOFDMFrame(preambleNumber * (FFTSize + CPLength) + 1:end);
    recovered = FFT(recvOFDMSignal);

    % 使用估计出的信道信息
    for i = 1:SToPcol;
        recovered(:, i) = recovered(:, i) ./ H(DataCarrierPositions);
    end

    % 除对应功率
    if on == 1
        load('./data/power_alloc.mat');

        for i = 1:SToPcol
            recovered(DataCarrierPositions - 2, i) = recovered(DataCarrierPositions - 2, i) ./ sqrt(power_alloc');
        end

    else
        recovered = reshape(recovered, [], 1);
    end

    % display(rms(recovered))
    recoveredSymbols_FDE = recovered / rms(recovered);

    decodedMsg_HD = QAM2Bits(recovered);

    if On == 1

        for iter = 1:Iteration
            decodedMsg_HD = iteration_alloc(decodedMsg_HD, OFDMParameters, tblen, recovered, cir);
        end

    else

        for i = 1:Iteration
            decodedMsg_HD = iteration(decodedMsg_HD, OFDMParameters, tblen, i, recoveredSymbols_FDE, cir);
        end

    end
