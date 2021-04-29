function [decoded] = OFDMFrameReceiver(recvOFDMFrame)
    global On
    global IsPreamble
    global PowerOn
    global Iteration
    global CPLength
    global DataCarrierPositions
    global PreambleNumber
    global SToPcol
    global FFTSize

    %% �ŵ����ƺ�����
    % hardware: ��ͬ�ڹ��ʷ���,�ŵ����Ʊ�Ȼ�Ƕ�̬��,�������ɰ뾲̬
    % �ŵ����ƺ�����������פ����FDE
    recvPreambleOFDMSymbols = recvOFDMFrame(1:PreambleNumber * (FFTSize + CPLength)); % ���յ�����֡��Ϊѵ�����к���Ϣ����
    recvMsgOFDMSymbols = recvOFDMFrame(PreambleNumber * (FFTSize + CPLength) + 1:end);

    IsPreamble = 1;
    reambleQAMSymbols = FFT(recvPreambleOFDMSymbols);

    IsPreamble = 0;
    FDE = FFT(recvMsgOFDMSymbols); % fft,FDE�ߴ�224*16

    H = ChannelEstimation(reambleQAMSymbols); % �ŵ�����,�õ�(ѵ��������ռ�ݵ�)�������ز��ϵ�����ϵ��,H�ߴ�255*1

    % �ŵ���?
    for i = 1:SToPcol;
        FDE(:, i) = FDE(:, i) ./ H(DataCarrierPositions - 1); % ?? �˴������ز������������
    end

    % ORIGINAL!
    % ����һ��,�õ�FDE

    %% ������������ͨ·
    % ��FDE��Ϊ��֧��һ֧ж�ع��ʷ���֮��������ͨ·����һֱ֧��פ���ڵ�����ڣ�������ж�ع��ʷ�������ڵ���ͨ·�м��ع��ʷ���
    FDEforIterating = FDE; % פ���ڵ������

    PowerOn = 0; % ȥ���ʷ���
    FDE = PowerOnOff(FDE);

    decoded = QAM2Bits(FDE); % QAM��ӳ�� -> �⽻֯ -> ά�ر�����

    % ?? FDEforIterating�Ƿ�Ҫ���й�һ��
    for iter = 1:Iteration
        decoded = Iterating(decoded, iter, FDEforIterating); % �ڽ��ջ��е�������,����,��ѵ��ģʽ�½��б��ط���
    end

    % ORIGINAL!!

    % dataQAMSymbols = IteratingBetter(FDE);

    % if On == 1 % ȥ���ʷ���
    %     PowerOn = 0;
    %     dataQAMSymbols = PowerOnOff(dataQAMSymbols);
    % end

    % decoded = QAM2Bits(dataQAMSymbols); % QAM��ӳ�� -> �⽻֯ -> ά�ر�����
