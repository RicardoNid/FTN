function QAMSymbols = DynamicQammod(bits, cir)
    global On
    global FFTSize
    global SToPcol
    global DataCarrierPositions
    global BitsPerSymbolQAM
    global OFDMSymbolNumber
    global RmsAlloc
    global SubcarriersNum

    ifftBlock = zeros(FFTSize, SToPcol);

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
                QAMSymbol = reshape(QAMSymbol, length(BitAllocSum{i}), SToPcol);
            end

            carrierPosition = BitAllocSum{i};
            % carrierPosition = carrierPosition + 2;
            % ifftBlock(carrierPosition, :) = QAMSymbol;
            QAMSymbols(carrierPosition, :) = QAMSymbol;

        end

        ifftBlock(DataCarrierPositions, :) = QAMSymbols;

        % % ���ʼ���
        % for i = 1:SToPcol
        %     ifftBlock(DataCarrierPositions, i) = ifftBlock(DataCarrierPositions, i) .* sqrt(power_alloc');
        % end

    else
        QAMSymbols = Qammod(BitsPerSymbolQAM, bits);
        QAMSymbols = QAMSymbols / RmsAlloc(4);

        % ʵ��ѵ��(on = 0)ʱ,����ѵ��֡������֪��,����ļ������ǺϷ���
        file = ['./data/QAMSymbols_trans' num2str(cir) '.mat'];
        save(file, 'QAMSymbols');
        QAMSymbols = reshape(QAMSymbols, length(DataCarrierPositions), SToPcol);
        ifftBlock(DataCarrierPositions, :) = QAMSymbols;
    end
