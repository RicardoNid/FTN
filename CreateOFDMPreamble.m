function preamble = CreateOFDMPreamble()
    global RmsAlloc
    global IsPreamble
    global PreambleBitsPerSymbolQAM
    global PreambleNumber
    global PreambleSeed
    global PreambleBitNumber

    %% �˲�������Ӳ��ʵ��
    preambleBits = randint(PreambleBitNumber, 1, 2, PreambleSeed);
    preambleQAMSymbols = GrayQAMCoder(preambleBits, PreambleBitsPerSymbolQAM);
    preambleQAMSymbols = preambleQAMSymbols / RmsAlloc(4);
    save './data/preambleQAMSymbols' preambleQAMSymbols % ѵ��QAM����,�洢�ڽ��ջ��뷢���

    %% ?? �˲�����ѵ�����е�QAM���ž�IFFT�õ�,����Ԥ�����洢�ڷ����,�д�����
    IsPreamble = 1;
    preamble = IFFT(preambleQAMSymbols);

    preamble = repmat(preamble, PreambleNumber, 1); %�ظ�2��
