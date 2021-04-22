function QAMSymbols = DynamicQammod(bits, cir)
    global On
    global FFTSize
    global SToPcol
    global DataCarrierPositions
    global BitsPerSymbolQAM
    global OFDMSymbolNumber
    global RmsAlloc
    global SubcarriersNum

    if On == 1
        %% bit loading %%
        load('./data/bitAlloc.mat')
        load('./data/bitAllocSort.mat');
        load('./data/BitAllocSum.mat');

        QAMSymbols = zeros(SubcarriersNum, SToPcol);

        b = 1;

        for i = 1:length(bitAllocSort)

            if bitAllocSort(i) == 0
                QAMSymbol = 0;
            else
                codeMsg1_per = OFDMSymbolNumber * bitAllocSort(i) * length(BitAllocSum{i}) * 2;
                codeMsg1_perloading = bits(b:b + codeMsg1_per - 1, 1);
                b = codeMsg1_per + b;
                QAMSymbol = Qammod(bitAllocSort(i), codeMsg1_perloading);
                QAMSymbol = QAMSymbol / RmsAlloc(bitAllocSort(i));
                % QAMSymbol = QAMSymbol / rms(QAMSymbol);
                QAMSymbol = reshape(QAMSymbol, length(BitAllocSum{i}), SToPcol);
            end

            carrierPosition = BitAllocSum{i};
            % carrierPosition = carrierPosition + 2;
            % ifftBlock(carrierPosition, :) = QAMSymbol;
            QAMSymbols(carrierPosition, :) = QAMSymbol;

        end

    else
        QAMSymbols = Qammod(BitsPerSymbolQAM, bits);
        QAMSymbols = QAMSymbols / RmsAlloc(4);
        % QAMSymbols = QAMSymbols / rms(QAMSymbols);

        % 实际训练(on = 0)时,整个训练帧都是已知的,因此文件传递是合法的
        file = ['./data/QAMSymbols_trans' num2str(cir) '.mat'];
        save(file, 'QAMSymbols');
        QAMSymbols = reshape(QAMSymbols, length(DataCarrierPositions), SToPcol);
    end
