function ifftBlock = DynamicQammod(bits, on, cir)
    global On
    global FFTSize
    global SToPcol
    global DataCarrierPositions
    global BitsPerSymbolQAM
    global OFDMSymbolNumber
    global RmsAlloc

    ifftBlock = zeros(FFTSize, SToPcol);

    if On == 1
        %% bit loading %%
        load('./data/bitAlloc.mat')
        load('./data/bitAllocSort.mat');
        load('./data/BitAllocSum.mat');
        load('./data/power_alloc.mat');

        b = 1;

        for i = 1:length(bitAllocSort)

            if bitAllocSort(i) == 0
                QAMSymbols = 0;
            else
                codeMsg1_per = OFDMSymbolNumber * bitAllocSort(i) * length(BitAllocSum{i}) * 2;
                codeMsg1_perloading = bits(b:b + codeMsg1_per - 1, 1);
                b = codeMsg1_per + b;
                QAMSymbols = Qammod(bitAllocSort(i), codeMsg1_perloading);
                QAMSymbols = QAMSymbols / RmsAlloc(bitAllocSort(i));
                QAMSymbols = reshape(QAMSymbols, length(BitAllocSum{i}), SToPcol);
            end

            carrierPosition = BitAllocSum{i};
            carrierPosition = carrierPosition + 2;
            ifftBlock(carrierPosition, :) = QAMSymbols;
        end

        % 功率加载
        for i = 1:SToPcol
            ifftBlock(DataCarrierPositions, i) = ifftBlock(DataCarrierPositions, i) .* sqrt(power_alloc');
        end

    else
        QAMSymbols = Qammod(BitsPerSymbolQAM, bits);
        QAMSymbols = QAMSymbols / RmsAlloc(4);

        % 实际训练(on = 0)时,整个训练帧都是已知的,因此文件传递是合法的
        file = ['./data/QAMSymbols_trans' num2str(cir) '.mat'];
        save(file, 'QAMSymbols');
        QAMSymbols = reshape(QAMSymbols, length(DataCarrierPositions), SToPcol);
        ifftBlock(DataCarrierPositions, :) = QAMSymbols;
    end
