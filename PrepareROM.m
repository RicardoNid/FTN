function none = PrepareROM()

    global RmsAlloc
    global PreambleBitsPerSymbolQAM
    global PreambleSeed
    global PreambleBitNumber
    global SubcarriersNum

    % global DoInterleave
    % DoInterleave = 1;

    %% ׼����������
    % δѵ��ʱ�ı��ط���,�������ز���ͬ
    bitAlloc = ones(SubcarriersNum, 1) * PreambleBitsPerSymbolQAM;
    [bitAllocSort, bitAllocSum] = bits_alloc_position_sum(bitAlloc');
    % δѵ��ʱ�Ĺ��ʷ���,�������ز���ͬ
    powerAlloc = ones(1, SubcarriersNum);
    % δѵ��ʱRAM�еķ���,ѵ����ᱻ����
    save './data/powerAlloc' powerAlloc;
    save './data/bitAlloc' bitAlloc
    save './data/bitAllocSort' bitAllocSort;
    save './data/bitAllocSum' bitAllocSum;

    %% ��ѵ�����ؼӹ�ΪQAM����
    preambleBits = randint(PreambleBitNumber, 1, 2, PreambleSeed);
    preambleQAMSymbols = GrayQAMCoder(preambleBits, PreambleBitsPerSymbolQAM);
    preambleQAMSymbols = preambleQAMSymbols / RmsAlloc(4);
    % ʵ��ʵ��ʱ,����/���ջ�����ROM�ж�ȡԤ�ȴ洢��ѵ������QAM����,ʵ����,���ļ���ȡ��ʽģ��
    save './data/preambleQAMSymbols' preambleQAMSymbols

    msgBits = BitGen(); % ��֡����Ϣ����
    %% ����Ϣ���ؼӹ�ΪQAM����
    msgQAMSymbols = Bits2QAM(msgBits); % ������� -> ��֯ -> QAMӳ��
    % ʵ��ʵ��ʱ,���ط���ʱ,����/���ջ�����ROM�ж�ȡԤ�ȴ洢��ѵ����֡��QAM����,ʵ����,���ļ���ȡ��ʽģ��
    save './data/msgQAMSymbols' msgQAMSymbols;
