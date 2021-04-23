function [H] = ChannelEstimationByPreamble(preamble)
    %% parameters
    global IsPreamble
    global PreambleNumber
    global PreambleCarriersNum

    % hardware: 此处为ROM
    load './data/preambleQAMSymbols' % 接收机内置preambleQAMSymbol的QAM符号序列

    %% 自此以下的部分需要硬件实现
    IsPreamble = 1;
    recvPreambleQAMSymbols = FFT(preamble);

    ratio = zeros(PreambleCarriersNum, PreambleNumber);

    for i = 1:PreambleNumber
        % 计算求得preamble符号和实际preamble符号的比值作为信道估计
        ratio(:, i) = recvPreambleQAMSymbols(:, i) ./ preambleQAMSymbols;
    end

    H = mean(ratio, 2); % 对两个比值序列求均值得到信道估计
