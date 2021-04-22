function decodedMsg_HD = iteration_alloc(decodedMsg_HD, OFDMParameters, tblen, RXSymbols, cir)
    global RmsAlloc
    global FFTSize
    global SToPcol
    global DataCarrierPositions

    load('./data/bitAllocSort.mat');
    load('./data/BitAllocSum.mat');
    load('./data/power_alloc.mat');

    QAMSymbols = Bits2QAM(decodedMsg_HD, cir);

    ifftBlock = zeros(FFTSize, SToPcol);
    ifftBlock(DataCarrierPositions, :) = QAMSymbols;

    for i = 1:SToPcol
        ifftBlock(DataCarrierPositions, i) = ifftBlock(DataCarrierPositions, i) .* sqrt(power_alloc');
    end

    OFDMSymbols = IFFT(ifftBlock);
    recovered = FFT(OFDMSymbols);

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

    decodedMsg_HD = QAM2Bits(dataQAMSymbols);
