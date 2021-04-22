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

    decodedMsg_HD = QAM2Bits(dataQAMSymbols);
