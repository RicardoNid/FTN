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
    iterationT = OFDMParameters.iteration;
    CPLength = OFDMParameters.CPLength;
    BitsPerSymbolQAM = OFDMParameters.BitsPerSymbolQAM;
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
        recoveredSymbols = reshape(recovered, [], 1);
    end

    if on == 1
        %% bit loading %%
        load('./data/bitAllocSort.mat');
        load('./data/BitAllocSum.mat');
        demodulated_HD = [];

        for i = 1:length(bitAllocSort)

            if bitAllocSort(i) ~= 0
                carrierPosition = BitAllocSum{i};
                QAM = reshape(recovered(carrierPosition, :), [], 1);
                QAM_re = QAM / rms(QAM) * RmsAlloc(bitAllocSort(i));
                % de-mapping
                M = 2^bitAllocSort(i);

                if bitAllocSort(i) == 3 %QAM8
                    carrierPosition = BitAllocSum{i};
                    outPut = reshape(recovered(carrierPosition, :), [], 1);
                    outPut = outPut';
                    QAM8 = [-1 - sqrt(3), -1 + 1i, -1 - 1i, 1i * (1 + sqrt(3)), -1i * (1 + sqrt(3)), 1 + 1i, 1 - 1i, 1 + sqrt(3)] ./ sqrt(3 + sqrt(3));
                    [~, index] = min(abs(repmat(outPut, 8, 1) - repmat(transpose(QAM8), 1, length(outPut))));
                    temp = de2bi(index - 1, 3, 'left-msb');
                    demodulatedMsg_HD = reshape(temp', 1, []);
                else
                    modObj = modem.qammod('M', M, 'SymbolOrder', 'Gray', 'InputType', 'Bit');
                    demodObj = modem.qamdemod(modObj);
                    set(demodObj, 'DecisionType', 'Hard decision');
                    demodulatedMsg_HD = demodulate(demodObj, QAM_re);
                    demodulatedMsg_HD = demodulatedMsg_HD';
                end

                % decisiong
                % Set up the demodulator object to perform hard decision demodulation
                demodulated_HD = [demodulated_HD, demodulatedMsg_HD];
            end

        end

        deinterleavedMsg = Deinterleave(demodulated_HD);
        demodulatedMsg_HD = deinterleavedMsg(:);

        decodedMsg_HD = Vitdec(demodulatedMsg_HD);

        % iteration
        for iter = 1:iterationT
            % (9) // =====================带有误码率的输出=====================================
            %   [PerQAMtotal,PerQAMError,QAM_re_sum,pre_code_errors,decodedMsg_HD,number_of_error_HD]=iteration_alloc(decodedMsg_HD,OFDMParameters,tblen,iter,recovered, cir);
            %  // =====================不带误码率的输出=====================================
            decodedMsg_HD = iteration_alloc(decodedMsg_HD, OFDMParameters, tblen, recovered, cir);
        end

        % (10) // ==========================================================
        %     将错误数输出，在OFDM_test中算误码率
        %      number_of_error = number_of_error_HD;
        %  // ==========================================================
    else
        %% cal %%
        recoveredSymbols = recoveredSymbols / rms(recoveredSymbols) * sqrt(10);
        recoveredSymbols_FDE = recoveredSymbols;
        % Code properties(channel coding)

        % de-mapping
        M = 2^BitsPerSymbolQAM;
        modObj = modem.qammod('M', M, 'SymbolOrder', 'Gray', 'InputType', 'Bit');
        demodObj = modem.qamdemod(modObj);

        % decisiong
        % Set up the demodulator object to perform hard decision demodulation
        set(demodObj, 'DecisionType', 'Hard decision');
        demodulatedMsg_HD = demodulate(demodObj, recoveredSymbols);
        demodulatedMsg_HD = demodulatedMsg_HD';

        deinterleavedMsg = Deinterleave(demodulatedMsg_HD);
        demodulatedMsg_HD = deinterleavedMsg(:);
        decodedMsg_HD = Vitdec(demodulatedMsg_HD);
        %iteration
        for i = 1:iterationT
            decodedMsg_HD = iteration(decodedMsg_HD, OFDMParameters, tblen, i, recoveredSymbols_FDE, cir);
        end

    end
