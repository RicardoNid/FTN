function none = PrepareROM()

    global RmsAlloc
    global PreambleBitsPerSymbolQAM
    global PreambleSeed
    global PreambleBitNumber

    %% 将训练比特加工为QAM符号
    preambleBits = randint(PreambleBitNumber, 1, 2, PreambleSeed);
    preambleQAMSymbols = GrayQAMCoder(preambleBits, PreambleBitsPerSymbolQAM);
    preambleQAMSymbols = preambleQAMSymbols / RmsAlloc(4);
    % 实际实现时,发射/接收机都从ROM中读取预先存储的训练序列QAM符号,实验中,以文件存取形式模拟
    save './data/preambleQAMSymbols' preambleQAMSymbols

    msgBits = BitGen(); % 子帧的信息比特
    %% 将信息比特加工为QAM符号
    msgQAMSymbols = Bits2QAM(msgBits); % 卷积编码 -> 交织 -> QAM映射
    % 实际实现时,比特分配时,发射/接收机都从ROM中读取预先存储的训练子帧的QAM符号,实验中,以文件存取形式模拟
    save './data/msgQAMSymbols' msgQAMSymbols;
