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
        preambles = reshape(OFDMSignals, [], PreambleNumber); % ���յ�����preamble
        preamblesWithOutCP = preambles(CPLength / 2 + 1:end - CPLength / 2, :); % ȥ��ѭ��ǰ׺
        recvQAMSignal = fft(preamblesWithOutCP); % FFT�⸴��, ��preamble����
        OFDMSymbols = recvQAMSignal(PreambleCarrierPositions, :); % ȡ��preamble����
    else
        OFDMSignals = reshape(OFDMSignals, [], SToPcol); % S2P
        OFDMSignals = OFDMSignals(CPLength / 2 + 1:end - CPLength / 2, :); % ȥ��CP
        fftBlock = zeros(FFTSize, SToPcol);
        fftBlock(1:length(OFDMPositions), :) = OFDMSignals;
        OFDMSignals = fft(fftBlock);
        OFDMSymbols = OFDMSignals(DataCarrierPositions, :);
    end
