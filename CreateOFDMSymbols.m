function [OFDMSymbols, bitsPerFrame] = CreateOFDMSymbols(OFDMParameters, cir)

    global On
    global FFTSize
    global SToPcol
    global DataCarrierPositions

    bits = BitGen(cir);
    bitsPerFrame = bits;

    convCodedMsg = Convenc(bits);
    interleavedMsg = Interleave(convCodedMsg);

    ifftBlock = zeros(FFTSize, SToPcol);

    % ifftBlock = DynamicQammod(interleavedMsg, cir);
    QAMSymbols = DynamicQammod(interleavedMsg, cir);
    ifftBlock(DataCarrierPositions, :) = QAMSymbols;

    if On == 1
        load('./data/power_alloc.mat');

        for i = 1:SToPcol
            ifftBlock(DataCarrierPositions, i) = ifftBlock(DataCarrierPositions, i) .* sqrt(power_alloc');
        end

    end

    OFDMSymbols = IFFT(ifftBlock);
