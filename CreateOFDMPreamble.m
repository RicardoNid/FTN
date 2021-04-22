function preamble = CreateOFDMPreamble()
    global RmsAlloc
    global PreambleCarrierPositions
    global PreambleBitsPerSymbolQAM
    global FFTSize
    global PreambleNumber
    global PreambleSeed
    global PreambleBitNumber

    preambleBits = randint(PreambleBitNumber, 1, 2, PreambleSeed);
    save './data/preambleBits' preambleBits

    preambleQAMSymbols = GrayQAMCoder(preambleBits, PreambleBitsPerSymbolQAM);
    preambleQAMSymbols = preambleQAMSymbols / RmsAlloc(4);

    ifftBlock = zeros(FFTSize, 1);
    ifftBlock(PreambleCarrierPositions) = preambleQAMSymbols;
    ifftBlock(FFTSize + 2 - PreambleCarrierPositions) = conj(preambleQAMSymbols);

    preamble = ifft(ifftBlock);
    preamble = AddCP(preamble);

    save './data/preamble' preamble

    preamble = repmat(preamble, PreambleNumber, 1); %÷ÿ∏¥2¥Œ
