function OFDMSymbols = CreateOFDMSymbols(bits)
    global On
    global IsPreamble
    global PowerOn
    global RmsAlloc
    global BitsPerSymbolQAM

    QAMSymbols = Bits2QAM(bits); % ������� -> ��֯ -> QAMӳ��

    % ����QAMSymbols���ڱ��ط���
    % ʵ��ʵ����,���ط�����ù̶�����֡,��Ӧ��QAM����,ͬʱ�洢�ڽ��ջ��뷢���

    QAMSymbolsForAlloc = QAMSymbols * RmsAlloc(BitsPerSymbolQAM);
    save './data/QAMSymbolsForAlloc' QAMSymbolsForAlloc;

    if On == 1 % ����ʱ,����ѵ�����,ÿ�����ز�������Ӧ�ȹ���
        PowerOn = 1;
        QAMSymbols = PowerOnOff(QAMSymbols);
    end

    IsPreamble = 0;
    OFDMSymbols = IFFT(QAMSymbols); % ifft
