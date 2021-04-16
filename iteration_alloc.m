function decodedMsg_HD = iteration_alloc(decodedMsg_HD, OFDMParameters, tblen, RXSymbols, cir)
    FFTSize = OFDMParameters.FFTSize;
    OFDMSymbolNumber = OFDMParameters.OFDMSymbolNumber;
    DataCarrierPositions = OFDMParameters.DataCarrierPositions;
    SToPcol = OFDMParameters.SToPcol;

    convCodedMsg = Convenc(decodedMsg_HD);
    interleavedMsg = Interleave(convCodedMsg);

    %% mapping
    load('./data/bitAllocSort.mat');
    load('./data/BitAllocSum.mat');
    load('./data/power_alloc.mat');
    rmsAlloc = [];
    ifftBlock = zeros(FFTSize, SToPcol);

    b = 1;

    for i = 1:length(bitAllocSort)

        if bitAllocSort(i) == 0
            rmsAlloc = 0;
        else
            % mapping���Դ���qammod)
            if bitAllocSort(i) ~= 0
                M = 2^bitAllocSort(i);
                modObj = modem.qammod('M', M, 'SymbolOrder', 'Gray', 'InputType', 'Bit');
                codeMsg1_per = OFDMSymbolNumber * bitAllocSort(i) * length(BitAllocSum{i}) * 2;
                codeMsg1_perloading = interleavedMsg(b:b + codeMsg1_per - 1, 1);
                b = codeMsg1_per + b;

                if bitAllocSort(i) == 3 % QAM8
                    QAM8 = [-1 - sqrt(3), -1 + 1i, -1 - 1i, 1i * (1 + sqrt(3)), -1i * (1 + sqrt(3)), 1 + 1i, 1 - 1i, 1 + sqrt(3)];
                    qam8bit = reshape(codeMsg1_perloading, bitAllocSort(i), [])';
                    qam8dec = bi2de(qam8bit, 'left-msb');
                    QAMSymbols = QAM8(qam8dec + 1);
                    QAMSymbols = QAMSymbols';
                else
                    QAMSymbols = modulate(modObj, codeMsg1_perloading);
                end

                rms_alloc = rms(QAMSymbols);
                rmsAlloc = [rmsAlloc; rms_alloc];

                if bitAllocSort(i) == 0
                    QAMSymbols = 0;
                else
                    QAMSymbols = QAMSymbols / rms_alloc;
                    QAMSymbols = reshape(QAMSymbols, length(BitAllocSum{i}), SToPcol);
                end

                carrierPosition = BitAllocSum{i};
                carrierPosition = carrierPosition + 2;
                ifftBlock(carrierPosition, :) = QAMSymbols;
            end

        end

    end

    load('./data/power_alloc.mat');

    for i = 1:SToPcol
        ifftBlock(DataCarrierPositions, i) = ifftBlock(DataCarrierPositions, i) .* sqrt(power_alloc');
    end

    %% �ṹ�򵥣���ICI
    %% IFFT(zeros padding)
    OFDMSymbols = IFFT(ifftBlock);
    %% FFT(zeros padding)
    recovered = RecoverOFDMSymbols(OFDMSymbols, OFDMParameters);
    %% ����ICI
    QAMSymbols_trans0 = ifftBlock(DataCarrierPositions, :);
    ICI = recovered - QAMSymbols_trans0;
    %% �ӽ��ն˵�ԭʼ�ź���ȥ��ICI
    for i = 1:SToPcol % �����źŽ���û�н��й��ʷ��� % RXSymbolsΪ���ն�FFT����ź�
        RXSymbols(DataCarrierPositions - 2, i) = RXSymbols(DataCarrierPositions - 2, i) .* sqrt(power_alloc');
    end

    dataQAMSymbols = RXSymbols - ICI;
    %% �����ʷ���
    for i = 1:SToPcol
        dataQAMSymbols(DataCarrierPositions - 2, i) = dataQAMSymbols(DataCarrierPositions - 2, i) ./ sqrt(power_alloc');
    end

    %% receiver
    demodulated_HD = [];

    for i = 1:length(bitAllocSort)

        if bitAllocSort(i) ~= 0
            carrierPosition = BitAllocSum{i};
            QAM = reshape(dataQAMSymbols(carrierPosition, :), [], 1);
            QAM_re = QAM / rms(QAM) * rmsAlloc(i);
            % (15) // ======================================================================
            % Ϊ�˻��������������ͼ
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
