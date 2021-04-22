function [H] = ChannelEstimationByPreamble(recvPreamble)
    %% parameters
    global PreambleBitsPerSymbolQAM
    global PreambleCarrierPositions
    global FFTSize
    global CPLength
    global PreambleNumber
    global PreambleCarriersNum

    load './data/preambleBits'

    GQAMSymbols = GrayQAMCoder(preambleBits, PreambleBitsPerSymbolQAM);

    recvPreambleSignal = reshape(recvPreamble, FFTSize + CPLength, []);
    recvPreambleSignal = recvPreambleSignal(CPLength / 2 + 1:end - CPLength / 2, :);

    recvQAMSignal = fft(recvPreambleSignal);
    recvQAMSignal = recvQAMSignal(PreambleCarrierPositions, :);

    H_temp = zeros(PreambleCarriersNum, PreambleNumber);

    for i = 1:PreambleNumber
        H_temp(:, i) = recvQAMSignal(:, i) ./ GQAMSymbols * sqrt(10);
    end

    H = mean(H_temp, 2);
