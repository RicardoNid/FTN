function OFDMSymbols = CreateOFDMSymbols(bits)
    global On
    global PowerOn

    QAMSymbols = Bits2QAM(bits); % ������� -> ��֯ -> QAMӳ��

    % ����QAMSymbols���ڱ��ط���
    % ʵ��ʵ����,���ط�����ù̶�����֡,��Ӧ��QAM����,ͬʱ�洢�ڽ��ջ��뷢���
    file = './data/QAMSymbols_trans.mat';
    save(file, 'QAMSymbols');

    if On == 1 % ����ʱ,����ѵ�����,ÿ�����ز�������Ӧ�ȹ���
        PowerOn = 1;
        QAMSymbols = PowerOnOff(QAMSymbols);
    end

    OFDMSymbols = IFFT(QAMSymbols); % ifft
