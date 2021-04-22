function QAMSymbols = Bits2QAM(bits, cir)
    global DataCarrierPositions
    global SToPcol
    convCodedMsg = Convenc(bits);
    interleavedMsg = Interleave(convCodedMsg);
    QAMSymbols = DynamicQammod(interleavedMsg, cir); %  QAM映射
