function dataQAMSymbols = IteratingBetter(FDE)
    global On
    global IsPreamble
    global PowerOn
    global RmsAlloc
    global Iteration

    %% ����FDE����������������ϸ����,֮ǰ���⹦�ʷ���ͬʱȥ���Ƕ��ⲿ��QAM��ӳ�������Ӱ��,�����ǹ��ʷ����ۻ�
    % Iterating���Ǿֲ�������,FDE����û��side effcet,��˸Ļ�FDE
    % ����һ��˵,matlabû�а����ô���,ֻ�а�ֵ����,��������side effctֻ��ͨ������ֵ����

    dataQAMSymbols = FDE;

    for iter = 1:Iteration

        PowerOn = 0; % ȥ���ʷ���
        dataQAMSymbols = PowerOnOff(dataQAMSymbols);

        recvBits = QAM2Bits(dataQAMSymbols); % QAM��ӳ�� -> �⽻֯ -> ά�ر�����

        %% ���ڴ˲��ִ���������μ�ͼNO-DMT DSP
        QAMSymbols = Bits2QAM(recvBits); % ��·1,QAMSymbols

        PowerOn = 1; % �ӹ��ʷ���
        QAMSymbols = PowerOnOff(QAMSymbols);

        IsPreamble = 0;
        OFDMSymbols = IFFT(QAMSymbols);

        recvQAMSymbols = FFT(OFDMSymbols); % ��·2,recovered

        %% ��·�㼯����
        ICI = recvQAMSymbols - QAMSymbols;
        dataQAMSymbols = FDE - ICI;

        if On == 0 && iter == Iteration
            % ?? �˴�����Ҳ�ǲ���Ҫ��
            dataQAMSymbols = dataQAMSymbols * RmsAlloc(4);
            Alloc(dataQAMSymbols);
        end

    end
