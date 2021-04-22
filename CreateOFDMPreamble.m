function preamble = CreateOFDMPreamble(OFDMParameters)
    global RmsAlloc
    bitsNumber = length(OFDMParameters.PreambleCarrierPositions) * OFDMParameters.PreambleBitsPerSymbolQAM;
    preambleBits = randint(bitsNumber, 1, 2, OFDMParameters.PreambleSeed);
    preambleQAMSymbols = GrayQAMCoder(preambleBits, OFDMParameters.PreambleBitsPerSymbolQAM);
    preambleQAMSymbols = preambleQAMSymbols / RmsAlloc(4);
    % preambleQAMSymbols = preambleQAMSymbols / rms(preambleQAMSymbols);

    ifftBlock = zeros(OFDMParameters.FFTSize, 1);
    ifftBlock(OFDMParameters.PreambleCarrierPositions) = preambleQAMSymbols;
    ifftBlock(OFDMParameters.FFTSize + 2 - OFDMParameters.PreambleCarrierPositions) = conj(preambleQAMSymbols);

    sig = ifft(ifftBlock);
    sig = AddCP(sig);
    preamble = repmat(sig, OFDMParameters.PreambleNumber, 1); %÷ÿ∏¥2¥Œ
