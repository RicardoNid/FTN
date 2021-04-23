function [H] = ChannelEstimationByPreamble(preamble)
    %% parameters
    global PreambleCarrierPositions
    global CPLength
    global PreambleNumber
    global PreambleCarriersNum

    % hardware: 此处为ROM
    load './data/preambleQAMSymbols' % 接收机内置preambleQAMSymbol的QAM符号序列

    %% 自此以下的部分需要硬件实现
    preambles = reshape(preamble, [], PreambleNumber); % 接收到两个preamble
    preamblesWithOutCP = preambles(CPLength / 2 + 1:end - CPLength / 2, :); % 去除循环前缀

    recvQAMSignal = fft(preamblesWithOutCP); % FFT解复用, 求preamble符号
    recvQAMSignal = recvQAMSignal(PreambleCarrierPositions, :); % 取出preamble符号

    ratio = zeros(PreambleCarriersNum, PreambleNumber);

    for i = 1:PreambleNumber
        % 计算求得preamble符号和实际preamble符号的比值作为信道估计
        ratio(:, i) = recvQAMSignal(:, i) ./ preambleQAMSymbols;
    end

    H = mean(ratio, 2); % 对两个比值序列求均值得到信道估计
