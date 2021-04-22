function decodedMsg_HD = iteration_alloc(decodedMsg_HD, OFDMParameters, tblen, RXSymbols, cir)
    DataCarrierPositions = OFDMParameters.DataCarrierPositions;
    SToPcol = OFDMParameters.SToPcol;
    global RmsAlloc
    global FFTSize
    global SToPcol
    global DataCarrierPositions

    convCodedMsg = Convenc(decodedMsg_HD);
    interleavedMsg = Interleave(convCodedMsg);

    %% mapping
    load('./data/bitAllocSort.mat');
    load('./data/BitAllocSum.mat');
    load('./data/power_alloc.mat');

    ifftBlock = zeros(FFTSize, SToPcol);

    % ifftBlock = DynamicQammod(interleavedMsg, cir);
    QAMSymbols = DynamicQammod(interleavedMsg, cir);
    ifftBlock(DataCarrierPositions, :) = QAMSymbols;

    load('./data/power_alloc.mat');

    for i = 1:SToPcol
        ifftBlock(DataCarrierPositions, i) = ifftBlock(DataCarrierPositions, i) .* sqrt(power_alloc');
    end

    %% 结构简单，算ICI
    %% IFFT(zeros padding)
    OFDMSymbols = IFFT(ifftBlock);
    %% FFT(zeros padding)
    recovered = FFT(OFDMSymbols);
    %% 计算ICI
    QAMSymbols_trans0 = ifftBlock(DataCarrierPositions, :);
    ICI = recovered - QAMSymbols_trans0;
    %% 从接收端的原始信号中去除ICI
    for i = 1:SToPcol % 接收信号进来没有进行功率分配 % RXSymbols为接收端FFT输出信号
        RXSymbols(DataCarrierPositions - 2, i) = RXSymbols(DataCarrierPositions - 2, i) .* sqrt(power_alloc');
    end

    dataQAMSymbols = RXSymbols - ICI;
    %% 除功率分配
    for i = 1:SToPcol
        dataQAMSymbols(DataCarrierPositions - 2, i) = dataQAMSymbols(DataCarrierPositions - 2, i) ./ sqrt(power_alloc');
    end

    %% receiver
    demodulated_HD = [];

    for i = 1:length(bitAllocSort)

        if bitAllocSort(i) ~= 0
            carrierPosition = BitAllocSum{i};
            QAM = reshape(dataQAMSymbols(carrierPosition, :), [], 1);
            QAM_re = QAM / rms(QAM) * RmsAlloc(bitAllocSort(i));
            % (15) // ======================================================================
            % 为了画最后的总体的星座图
            %         QAM_re_sum{i}= QAM_re;
            %  // ======================================================================
            %% Code properties(channel coding)

            %% de-mapping
            M = 2^bitAllocSort(i);

            if bitAllocSort(i) == 3 %QAM8
                carrierPosition = BitAllocSum{i};
                outPut = reshape(dataQAMSymbols(carrierPosition, :), [], 1);
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

            %% decisiong
            % Set up the demodulator object to perform hard decision demodulation
            demodulated_HD = [demodulated_HD, demodulatedMsg_HD];
        end

    end

    deinterleavedMsg = Deinterleave(demodulated_HD);

    demodulatedMsg_HD = deinterleavedMsg(:);
    decodedMsg_HD = Vitdec(demodulatedMsg_HD);
