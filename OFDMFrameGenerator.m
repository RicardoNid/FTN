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

    %% ����ͨ·
    %% ��ѵ�����ؼӹ�ΪQAM����

    preambleBits = randint(PreambleBitNumber, 1, 2, PreambleSeed);
    preambleQAMSymbols = GrayQAMCoder(preambleBits, PreambleBitsPerSymbolQAM);
    preambleQAMSymbols = preambleQAMSymbols / RmsAlloc(4);

    %% ����Ϣ���ؼӹ�ΪQAM����
    msgQAMSymbols = Bits2QAM(msgBits); % ������� -> ��֯ -> QAMӳ��

    if On == 1 % ����ʱ,����ѵ�����,ÿ�����ز�������Ӧ�ȹ���
        PowerOn = 1;
        msgQAMSymbols = PowerOnOff(msgQAMSymbols);
    end

    %% ��ѵ��QAM���żӹ�ΪOFDM����
    IsPreamble = 1;
    preambleOFDMSymbols = IFFT(preambleQAMSymbols);

    %% ����ϢQAM���żӹ�ΪOFDM����
    IsPreamble = 0;
    msgOFDMSymbols = IFFT(msgQAMSymbols); % ifft

    %% ƴ��ѵ������Ϣ����
    OFDMSymbols = [repmat(preambleOFDMSymbols, PreambleNumber, 1); msgOFDMSymbols];

    %% ��·��˵��
    % ʵ��ʵ��ʱ,����/���ջ�����ROM�ж�ȡԤ�ȴ洢��ѵ������QAM����,ʵ����,���ļ���ȡ��ʽģ��
    save './data/preambleQAMSymbols' preambleQAMSymbols
    % ����QAMSymbols���ڱ��ط���
    % ʵ��ʵ��ʱ,���ط���ʱ,����/���ջ�����ROM�ж�ȡԤ�ȴ洢��ѵ����֡��QAM����,ʵ����,���ļ���ȡ��ʽģ��
    QAMSymbolsForAlloc = msgQAMSymbols * RmsAlloc(BitsPerSymbolQAM);
    save './data/QAMSymbolsForAlloc' QAMSymbolsForAlloc;
