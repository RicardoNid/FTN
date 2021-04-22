function DataForCarriers = DynamicQammod(bits, on, cir)
    global SubcarriersNum
    global SToPcol
    global BitsPerSymbolQAM
    global OFDMSymbolNumber
    global RmsAlloc

    DataForCarriers = zeros(SubcarriersNum, SToPcol);
    Container = [];

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
            Msg = bits(begin:begin + OFDMSymbolNumber * bitAllocated * 2 - 1, 1); % 2���Ծ������
            begin = begin + OFDMSymbolNumber * bitAllocated * 2;
            QAMSymbol = Qammod(bitAllocated, Msg);
            QAMSymbol = QAMSymbol / RmsAlloc(bitAllocated);

        end

        Container = [Container; QAMSymbol];
    end

    DataForCarriers = reshape(Container, SubcarriersNum, SToPcol);

    if on == 1 % ���ʼ���

        for i = 1:SToPcol
            DataForCarriers(:, i) = DataForCarriers(:, i) .* sqrt(power_alloc');
        end

    end

    if on == 0 % ʵ��ѵ��(on = 0)ʱ,����ѵ��֡������֪��,����ļ������ǺϷ���
        QAMSymbols = reshape(DataForCarriers, [], 1);
        file = ['./data/QAMSymbols_trans' num2str(cir) '.mat'];
        save(file, 'QAMSymbols');
    end
