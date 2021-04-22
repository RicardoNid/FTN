function QAMSymbols = DynamicQammod(bits, cir)
    global On
    global SToPcol
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
                % QAMSymbol = QAMSymbol / rms(QAMSymbol); ??
                QAMSymbol = reshape(QAMSymbol, length(BitAllocSum{i}), SToPcol);
            end

            carrierPosition = BitAllocSum{i};
            QAMSymbols(carrierPosition, :) = QAMSymbol;
        end

    else
        QAMSymbols = Qammod(BitsPerSymbolQAM, bits);
        QAMSymbols = QAMSymbols / RmsAlloc(4);

        if cir == 20
            file = ['./data/QAMSymbols_trans' num2str(20) '.mat'];
            save(file, 'QAMSymbols');
        end

        QAMSymbols = reshape(QAMSymbols, SubcarriersNum, SToPcol);
    end
