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
    preamble = recvOFDMFrame(1:PreambleNumber * (FFTSize + CPLength)); % ���յ�����֡��Ϊѵ�����к���Ϣ����
    message = recvOFDMFrame(PreambleNumber * (FFTSize + CPLength) + 1:end);

    IsPreamble = 1;
    reambleQAMSymbols = FFT(preamble);

    H = ChannelEstimationByPreamble(reambleQAMSymbols); % �ŵ�����,�õ�(ѵ��������ռ�ݵ�)�������ز��ϵ�����ϵ��,H�ߴ�255*1
    tap = 20;
    H = smooth(H, tap); % ������ϵ����spanΪ20�Ļ���ƽ��

    IsPreamble = 0;
    FDE = FFT(message); % fft,FDE�ߴ�224*16

    % �ŵ���?
    for i = 1:SToPcol;
        FDE(:, i) = FDE(:, i) ./ H(DataCarrierPositions - 1); % ?? �˴������ز������������
    end

    % ����һ��,פ����FDE�Ѿ�ȷ��

    %% ������������ͨ·
    % ��FDE��Ϊ��֧��һ֧ȥ�����ʷ���֮��������ͨ·����һֱ֧��פ���ڵ�����ڣ�������ȥ�����ʷ�������ڵ���ͨ·�м��ع��ʷ���
    FDEforIterating = FDE; % פ���ڵ������

    if On == 1 % ����ʱ,����ѵ�����,ÿ�����ز�������Ӧ����
        PowerOn = 0;
        FDE = PowerOnOff(FDE);
    end

    decoded = QAM2Bits(FDE); % QAM��ӳ�� -> �⽻֯ -> ά�ر�����

    % ?? FDEforIterating�Ƿ�Ҫ���й�һ��
    for iter = 1:Iteration
        decoded = Iterating(decoded, iter, FDEforIterating); % �ڽ��ջ��е�������,����,��ѵ��ģʽ�½��б��ط���
    end
