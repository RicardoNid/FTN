function decoded = Iterating(decoded, i, FDE)
    global On
    global IsPreamble
    global PowerOn
    global RmsAlloc
    global Iteration
    global CurrentFrame
    global FrameNum

    %% 关于FDE的命名我又做了仔细考虑,之前内外功率分配同时去除是对外部的QAM解映射产生了影响,而不是功率分配累积
    % Iterating内是局部作用域,FDE命名没有side effcet,因此改回FDE
    % 更进一步说,matlab没有按引用传递,只有按值传递,所以所有side effct只能通过返回值产生

    %% 关于此部分代码的理解请参见图NO-DMT DSP
    QAMSymbols = Bits2QAM(decoded); % 旁路1,QAMSymbols

    if On == 1 % 加功率分配
        PowerOn = 1;
        QAMSymbols = PowerOnOff(QAMSymbols);
    end

    IsPreamble = 0;
    OFDMSymbols = IFFT(QAMSymbols);

    recovered = FFT(OFDMSymbols); % 旁路2,recovered

    %% 旁路汇集部分
    ICI = recovered - QAMSymbols;
    dataQAMSymbols = FDE - ICI;

    if On == 1 % 去功率分配
        PowerOn = 0;
        dataQAMSymbols = PowerOnOff(dataQAMSymbols);
    end

    decoded = QAM2Bits(dataQAMSymbols);

    if On == 0 && i == Iteration
        % ?? 此处可能也是不必要的
        dataQAMSymbols = dataQAMSymbols * RmsAlloc(4);

        Alloc(dataQAMSymbols);

    end
