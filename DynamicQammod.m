function DataForCarriers = DynamicQammod(bits, on)
    global SubcarriersNum
    global SToPcol
    global BitsPerSymbolQAM
    global OFDMSymbolNumber
    global RmsAlloc

    DataForCarriers = zeros(SubcarriersNum, SToPcol);

    if on == 1
        load('./data/bitAlloc.mat')
        load('./data/power_alloc.mat');
    end

    begin = 1;

    for i = 1:SubcarriersNum

        if on == 1
            bitAllocated = bitAlloc(i);
        else
            bitAllocated = BitsPerSymbolQAM;
        end

        if bitAllocated == 0
            QAMSymbol = 0;
        else
            Msg = bits(begin:begin + OFDMSymbolNumber * bitAllocated * 2 - 1, 1); % 2来自卷积编码
            begin = begin + OFDMSymbolNumber * bitAllocated * 2;
            QAMSymbol = Qammod(bitAllocated, Msg);
            QAMSymbol = QAMSymbol / RmsAlloc(bitAllocated);
            QAMSymbol = reshape(QAMSymbol, 1, SToPcol);
        end

        DataForCarriers(i, :) = QAMSymbol;
    end

    if on == 1 % 功率加载

        for i = 1:SToPcol
            DataForCarriers(:, i) = DataForCarriers(:, i) .* sqrt(power_alloc');
        end

    end

    if on == 0 % 实际训练(on = 0)时,整个训练帧都是已知的,因此文件传递是合法的
        QAMSymbols = reshape(DataForCarriers, [], 1);
        file = './data/QAMSymbols_trans.mat';
        save(file, 'QAMSymbols');
    end
