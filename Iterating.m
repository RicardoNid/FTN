function decodedMsg_HD = Iterating(decodedMsg_HD, i, FDEInner)
    global On
    global RmsAlloc
    global SToPcol
    global DataCarrierPositions
    global Iteration
    global CurrentFrame
    global FrameNum

    %% 关于此部分代码的理解请参见图NO-DMT DSP
    QAMSymbols = Bits2QAM(decodedMsg_HD); % 旁路1,QAMSymbols

    if On == 1
        load('./data/power_alloc.mat');

        for i = 1:SToPcol
            QAMSymbols(:, i) = QAMSymbols(:, i) .* sqrt(power_alloc');
        end

    end

    OFDMSymbols = IFFT(QAMSymbols);

    recovered = FFT(OFDMSymbols); % 旁路2,recovered

    %% 旁路汇集部分
    ICI = recovered - QAMSymbols;
    dataQAMSymbols = FDEInner - ICI;
    %% 除功率分配
    if On == 1

        for i = 1:SToPcol
            dataQAMSymbols(DataCarrierPositions - 2, i) = dataQAMSymbols(DataCarrierPositions - 2, i) ./ sqrt(power_alloc');
        end

    end

    decodedMsg_HD = QAM2Bits(dataQAMSymbols);

    if On == 0 && CurrentFrame == FrameNum && i == Iteration
        % ?? 此处可能也是不必要的
        dataQAMSymbols = dataQAMSymbols * RmsAlloc(4);

        Alloc(dataQAMSymbols);

    end
