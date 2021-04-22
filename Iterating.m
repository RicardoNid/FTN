function decodedMsg_HD = iteration_alloc(decodedMsg_HD, OFDMParameters, tblen, i, FDE, cir)
    global On
    global RmsAlloc
    global FFTSize
    global SToPcol
    global DataCarrierPositions
    global Iteration

    QAMSymbols = Bits2QAM(decodedMsg_HD, cir);

    if On == 1
        load('./data/power_alloc.mat');

        for i = 1:SToPcol
            QAMSymbols(:, i) = QAMSymbols(:, i) .* sqrt(power_alloc');
        end

    end

    ifftBlock = zeros(FFTSize, SToPcol);
    ifftBlock(DataCarrierPositions, :) = QAMSymbols;

    OFDMSymbols = IFFT(ifftBlock);
    recovered = FFT(OFDMSymbols);

    if On == 1
        % 接收信号进来没有进行功率分配 % FDE为接收端FFT输出信号
        for i = 1:SToPcol
            FDE(DataCarrierPositions - 2, i) = FDE(DataCarrierPositions - 2, i) .* sqrt(power_alloc');
        end

    else
        FDE = FDE / rms(FDE);

        QAMSymbols = reshape(QAMSymbols, [], 1);
        recovered = reshape(recovered, [], 1);

    end

    ICI = recovered - QAMSymbols;
    dataQAMSymbols = FDE - ICI;
    %% 除功率分配
    if On == 1

        for i = 1:SToPcol
            dataQAMSymbols(DataCarrierPositions - 2, i) = dataQAMSymbols(DataCarrierPositions - 2, i) ./ sqrt(power_alloc');
        end

    end

    decodedMsg_HD = QAM2Bits(dataQAMSymbols);

    if On == 0
        % 此处可能也是不必要的
        dataQAMSymbols = dataQAMSymbols * RmsAlloc(4);

        if cir == 20 && i == Iteration
            Alloc(dataQAMSymbols);
        end

    end
