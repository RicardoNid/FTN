function preamble = CreateOFDMPreamble()
    global RmsAlloc
    global PreambleCarrierPositions
    global PreambleBitsPerSymbolQAM
    global FFTSize
    global PreambleNumber
    global PreambleSeed

    bitsNumber = length(PreambleCarrierPositions) * PreambleBitsPerSymbolQAM;

    preambleBits = randint(bitsNumber, 1, 2, PreambleSeed);
    preambleQAMSymbols = GrayQAMCoder(preambleBits, PreambleBitsPerSymbolQAM);
    preambleQAMSymbols = preambleQAMSymbols / RmsAlloc(4);
    % preambleQAMSymbols = preambleQAMSymbols / rms(preambleQAMSymbols);

    ifftBlock = zeros(FFTSize, 1);
    ifftBlock(PreambleCarrierPositions) = preambleQAMSymbols;
    ifftBlock(FFTSize + 2 - PreambleCarrierPositions) = conj(preambleQAMSymbols);

    sig = ifft(ifftBlock);
    sig = AddCP(sig);
    preamble = repmat(sig, PreambleNumber, 1); %÷ÿ∏¥2¥Œ
