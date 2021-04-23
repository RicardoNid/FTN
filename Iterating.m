function decodedMsg_HD = Iterating(decodedMsg_HD, i, FDEInner)
    global On
    global RmsAlloc
    global SToPcol
    global DataCarrierPositions
    global Iteration
    global CurrentFrame
    global FrameNum

    %% ���ڴ˲��ִ���������μ�ͼNO-DMT DSP
    QAMSymbols = Bits2QAM(decodedMsg_HD); % ��·1,QAMSymbols

    if On == 1
        load('./data/power_alloc.mat');

        for i = 1:SToPcol
            QAMSymbols(:, i) = QAMSymbols(:, i) .* sqrt(power_alloc');
        end

    end

    OFDMSymbols = IFFT(QAMSymbols);

    recovered = FFT(OFDMSymbols); % ��·2,recovered

    %% ��·�㼯����
    ICI = recovered - QAMSymbols;
    dataQAMSymbols = FDEInner - ICI;
    %% �����ʷ���
    if On == 1

        for i = 1:SToPcol
            dataQAMSymbols(DataCarrierPositions - 2, i) = dataQAMSymbols(DataCarrierPositions - 2, i) ./ sqrt(power_alloc');
        end

    end

    decodedMsg_HD = QAM2Bits(dataQAMSymbols);

    if On == 0 && CurrentFrame == FrameNum && i == Iteration
        % ?? �˴�����Ҳ�ǲ���Ҫ��
        dataQAMSymbols = dataQAMSymbols * RmsAlloc(4);

        Alloc(dataQAMSymbols);

    end
