function [H] = ChannelEstimationByPreamble(preamble)
    %% parameters
    global PreambleCarrierPositions
    global CPLength
    global PreambleNumber
    global PreambleCarriersNum

    load './data/preambleQAMSymbols' % ���ջ�����preambleQAMSymbol��QAM��������

    %% �Դ����µĲ�����ҪӲ��ʵ��
    recvPreambleSignal = reshape(preamble, [], PreambleNumber); % ���յ�����preamble
    recvPreambleSignal = recvPreambleSignal(CPLength / 2 + 1:end - CPLength / 2, :); % ȥ��ѭ��ǰ׺

    recvQAMSignal = fft(recvPreambleSignal); % FFT��preamble����
    recvQAMSignal = recvQAMSignal(PreambleCarrierPositions, :); % ȡ��preamble����

    ratio = zeros(PreambleCarriersNum, PreambleNumber);

    for i = 1:PreambleNumber
        % �������preamble���ź�ʵ��preamble���ŵı�ֵ��Ϊ�ŵ�����
        ratio(:, i) = recvQAMSignal(:, i) ./ preambleQAMSymbols;
    end

    H = mean(ratio, 2); % ��������ֵ�������ֵ�õ��ŵ�����
