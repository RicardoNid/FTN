function OFDMSymbols = FFT(recvOFDMSignal)

    global OFDMPositions;
    global DataCarrierPositions;
    global FFTSize;
    global CPLength;
    global SToPcol;

    recvOFDMSignal = reshape(recvOFDMSignal, [], SToPcol); % S2P
    recvOFDMSignal = recvOFDMSignal(CPLength / 2 + 1:end - CPLength / 2, :); % »•µÙCP
    fftBlock = zeros(FFTSize, SToPcol);
    fftBlock(1:length(OFDMPositions), :) = recvOFDMSignal;
    recvOFDMSignal = fft(fftBlock);
    OFDMSymbols = recvOFDMSignal(DataCarrierPositions, :);
