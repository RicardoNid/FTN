function preamble = CreateOFDMPreamble()
    global RmsAlloc
    global IsPreamble
    global PreambleBitsPerSymbolQAM
    global PreambleNumber
    global PreambleSeed
    global PreambleBitNumber

    %% 此部分无需硬件实现
    preambleBits = randint(PreambleBitNumber, 1, 2, PreambleSeed);
    preambleQAMSymbols = GrayQAMCoder(preambleBits, PreambleBitsPerSymbolQAM);
    preambleQAMSymbols = preambleQAMSymbols / RmsAlloc(4);
    save './data/preambleQAMSymbols' preambleQAMSymbols % 训练QAM符号,存储在接收机与发射机

    %% ?? 此部分是训练序列的QAM符号经IFFT得到,还是预计算后存储在发射机,有待讨论
    IsPreamble = 1;
    preamble = IFFT(preambleQAMSymbols);

    save './data/preamble' preamble % 训练OFDM符号,存储在发射机
    preamble = repmat(preamble, PreambleNumber, 1); %重复2次
