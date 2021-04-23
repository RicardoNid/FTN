function OFDMSymbols = FFT(OFDMSignals)
    global IsPreamble
    global OFDMPositions
    global PreambleNumber
    global PreambleCarrierPositions
    global DataCarrierPositions
    global FFTSize
    global CPLength
    global SToPcol

    if IsPreamble == 1
        preambles = reshape(OFDMSignals, [], PreambleNumber); % 接收到两个preamble
        preamblesWithOutCP = preambles(CPLength / 2 + 1:end - CPLength / 2, :); % 去除循环前缀
        recvQAMSignal = fft(preamblesWithOutCP); % FFT解复用, 求preamble符号
        OFDMSymbols = recvQAMSignal(PreambleCarrierPositions, :); % 取出preamble符号
    else
        OFDMSignals = reshape(OFDMSignals, [], SToPcol); % S2P
        OFDMSignals = OFDMSignals(CPLength / 2 + 1:end - CPLength / 2, :); % 去掉CP
        fftBlock = zeros(FFTSize, SToPcol);
        fftBlock(1:length(OFDMPositions), :) = OFDMSignals;
        OFDMSignals = fft(fftBlock);
        OFDMSymbols = OFDMSignals(DataCarrierPositions, :);
    end
