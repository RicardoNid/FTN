function [decoded] = OFDMFrameReceiver(recvOFDMFrame)
    global On
    global Iteration
    global CPLength
    global DataCarrierPositions
    global PreambleNumber
    global SToPcol
    global FFTSize

    %% �����ŵ���FFT
    preamble = recvOFDMFrame(1:PreambleNumber * (FFTSize + CPLength)); % ���յ�����֡��Ϊѵ�����к���Ϣ����
    message = recvOFDMFrame(PreambleNumber * (FFTSize + CPLength) + 1:end);

    H = ChannelEstimationByPreamble(preamble); % �ŵ�����,�õ�(ѵ��������ռ�ݵ�)�������ز��ϵ�����ϵ��,H�ߴ�255*1
    tap = 20;
    H = smooth(H, tap); % ������ϵ����spanΪ20�Ļ���ƽ��

    FDE = FFT(message); % fft,FDE�ߴ�224*16

    % ʹ�ù��Ƴ����ŵ���Ϣ
    for i = 1:SToPcol;
        FDE(:, i) = FDE(:, i) ./ H(DataCarrierPositions - 1); % ?? �˴������ز������������
    end

    % ��FDE��Ϊ��֧��һ֧ȥ�����ʷ���֮����н�ӳ�䣬��һֱ֧���������ͨ·��������ȥ�����ʷ�������ڵ���ͨ·�м��ع��ʷ���
    FDEforIterating = FDE;

    if On == 1 % ����ʱ,����ѵ�����,ÿ�����ز�������Ӧ����
        load('./data/power_alloc.mat'); % ���ʷ���,ѵ��ģʽ����ջ���������Ϣ֮һ,power_alloc�ߴ�1*224

        for i = 1:SToPcol
            FDE(DataCarrierPositions - 2, i) = FDE(DataCarrierPositions - 2, i) ./ sqrt(power_alloc'); % ��ȥ���ʷ���,FDE�ߴ�224*16
        end

    end

    decoded = QAM2Bits(FDE); % QAM��ӳ�� -> �⽻֯ -> ά�ر�����

    % ?? FDEforIterating�Ƿ�Ҫ���й�һ��
    for iter = 1:Iteration
        decoded = Iterating(decoded, iter, FDEforIterating); % �ڽ��ջ��е�������,����,��ѵ��ģʽ�½��б��ط���
    end
