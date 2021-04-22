function [H] = ChannelEstimationByPreamble(preamble)
    %% parameters
    global PreambleCarrierPositions
    global CPLength
    global PreambleNumber
    global PreambleCarriersNum

    load './data/preambleQAMSymbols' % 接收机内置preambleQAMSymbol的QAM符号序列

    %% 自此以下的部分需要硬件实现
    recvPreambleSignal = reshape(preamble, [], PreambleNumber); % 接收到两个preamble
    recvPreambleSignal = recvPreambleSignal(CPLength / 2 + 1:end - CPLength / 2, :); % 去除循环前缀

    recvQAMSignal = fft(recvPreambleSignal); % FFT求preamble符号
    recvQAMSignal = recvQAMSignal(PreambleCarrierPositions, :); % 取出preamble符号

    ratio = zeros(PreambleCarriersNum, PreambleNumber);

    for i = 1:PreambleNumber
        % 计算求得preamble符号和实际preamble符号的比值作为信道估计
        ratio(:, i) = recvQAMSignal(:, i) ./ preambleQAMSymbols;
    end

    H = mean(ratio, 2); % 对两个比值需求均值得到信道估计
