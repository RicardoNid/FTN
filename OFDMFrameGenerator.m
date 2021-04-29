function OFDMSymbols = OFDMFrameGenerator(msgBits)

    global On
    global IsPreamble
    global PowerOn
    global RmsAlloc
    global BitsPerSymbolQAM
    global PreambleBitsPerSymbolQAM
    global PreambleNumber
    global PreambleSeed
    global PreambleBitNumber

    %% 数据通路
    %% 将训练比特加工为QAM符号

    preambleBits = randint(PreambleBitNumber, 1, 2, PreambleSeed);
    preambleQAMSymbols = GrayQAMCoder(preambleBits, PreambleBitsPerSymbolQAM);
    preambleQAMSymbols = preambleQAMSymbols / RmsAlloc(4);

    %% 将信息比特加工为QAM符号
    msgQAMSymbols = Bits2QAM(msgBits); % 卷积编码 -> 交织 -> QAM映射

    if On == 1 % 工作时,根据训练结果,每个子载波分配相应比功率
        PowerOn = 1;
        msgQAMSymbols = PowerOnOff(msgQAMSymbols);
    end

    %% 将训练QAM符号加工为OFDM符号
    IsPreamble = 1;
    preambleOFDMSymbols = IFFT(preambleQAMSymbols);

    %% 将信息QAM符号加工为OFDM符号
    IsPreamble = 0;
    msgOFDMSymbols = IFFT(msgQAMSymbols); % ifft

    %% 拼接训练和信息序列
    OFDMSymbols = [repmat(preambleOFDMSymbols, PreambleNumber, 1); msgOFDMSymbols];

    %% 旁路和说明
    % 实际实现时,发射/接收机都从ROM中读取预先存储的训练序列QAM符号,实验中,以文件存取形式模拟
    save './data/preambleQAMSymbols' preambleQAMSymbols
    % 保存QAMSymbols用于比特分配
    % 实际实现时,比特分配时,发射/接收机都从ROM中读取预先存储的训练子帧的QAM符号,实验中,以文件存取形式模拟
    QAMSymbolsForAlloc = msgQAMSymbols * RmsAlloc(BitsPerSymbolQAM);
    save './data/QAMSymbolsForAlloc' QAMSymbolsForAlloc;
