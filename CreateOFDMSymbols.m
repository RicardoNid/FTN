function [OFDMSymbols, bitsPerFrame] = CreateOFDMSymbols(OFDMParameters, cir)

    bits = BitGen(cir);
    bitsPerFrame = bits;

    convCodedMsg = Convenc(bits);
    interleavedMsg = Interleave(convCodedMsg);
    ifftBlock = DynamicQammod(interleavedMsg, cir);
    OFDMSymbols = IFFT(ifftBlock);
