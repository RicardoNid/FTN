function [H] = ChannelEstimationByPreamble(recvPreambleQAMSymbols)
    global PreambleNumber
    global PreambleCarriersNum

    % hardware: �˴�ΪROM
    load './data/preambleQAMSymbols' % ���ջ�����preambleQAMSymbol��QAM��������

    %% �Դ����µĲ�����ҪӲ��ʵ��
    ratio = zeros(PreambleCarriersNum, PreambleNumber);

    for i = 1:PreambleNumber
        % �������preamble���ź�ʵ��preamble���ŵı�ֵ��Ϊ�ŵ�����
        ratio(:, i) = recvPreambleQAMSymbols(:, i) ./ preambleQAMSymbols;
    end

    H = mean(ratio, 2); % ��������ֵ�������ֵ�õ��ŵ�����
