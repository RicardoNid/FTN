function [H] = ChannelEstimationByPreamble(preamble)
    %% parameters
    global IsPreamble
    global PreambleNumber
    global PreambleCarriersNum

    % hardware: �˴�ΪROM
    load './data/preambleQAMSymbols' % ���ջ�����preambleQAMSymbol��QAM��������

    %% �Դ����µĲ�����ҪӲ��ʵ��
    IsPreamble = 1;
    recvPreambleQAMSymbols = FFT(preamble);

    ratio = zeros(PreambleCarriersNum, PreambleNumber);

    for i = 1:PreambleNumber
        % �������preamble���ź�ʵ��preamble���ŵı�ֵ��Ϊ�ŵ�����
        ratio(:, i) = recvPreambleQAMSymbols(:, i) ./ preambleQAMSymbols;
    end

    H = mean(ratio, 2); % ��������ֵ�������ֵ�õ��ŵ�����
