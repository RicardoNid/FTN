function decoded = Iterating(decoded, i, FDE)
    global On
    global IsPreamble
    global PowerOn
    global RmsAlloc
    global Iteration

    %% ����FDE����������������ϸ����,֮ǰ���⹦�ʷ���ͬʱȥ���Ƕ��ⲿ��QAM��ӳ�������Ӱ��,�����ǹ��ʷ����ۻ�
    % Iterating���Ǿֲ�������,FDE����û��side effcet,��˸Ļ�FDE
    % ����һ��˵,matlabû�а����ô���,ֻ�а�ֵ����,��������side effctֻ��ͨ������ֵ����

    %% ���ڴ˲��ִ���������μ�ͼNO-DMT DSP
    QAMSymbols = Bits2QAM(decoded); % ��·1,QAMSymbols

    PowerOn = 1; % �ӹ��ʷ���
    QAMSymbols = PowerOnOff(QAMSymbols);

    IsPreamble = 0;
    OFDMSymbols = IFFT(QAMSymbols);

    recovered = FFT(OFDMSymbols); % ��·2,recovered

    %% ��·�㼯����
    ICI = recovered - QAMSymbols;
    dataQAMSymbols = FDE - ICI;

    PowerOn = 0; % ȥ���ʷ���
    dataQAMSymbols = PowerOnOff(dataQAMSymbols);

    decoded = QAM2Bits(dataQAMSymbols);

    if On == 0 && i == Iteration
        % ?? �˴�����Ҳ�ǲ���Ҫ��
        dataQAMSymbols = dataQAMSymbols * RmsAlloc(4);

        Alloc(dataQAMSymbols);
    end
