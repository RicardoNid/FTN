function [OFDMSymbols, bitsPerFrame] = CreateOFDMSymbols(OFDMParameters, cir)

    global On
    global FFTSize
    global SToPcol
    global DataCarrierPositions

    bits = BitGen(cir);
    bitsPerFrame = bits; % ��·

    QAMSymbols = Bits2QAM(bits, cir);

    ifftBlock = zeros(FFTSize, SToPcol); % ����FFT����
    ifftBlock(DataCarrierPositions, :) = QAMSymbols;

    if On == 1
        load('./data/power_alloc.mat');

        for i = 1:SToPcol
            ifftBlock(DataCarrierPositions, i) = ifftBlock(DataCarrierPositions, i) .* sqrt(power_alloc');
        end

    end

    % OFDMSymbols = IFFT(QAMSymbols);
    OFDMSymbols = IFFT(ifftBlock);
