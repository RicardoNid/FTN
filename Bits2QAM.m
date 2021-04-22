function QAMSymbols = Bits2QAM(bits, cir)
    convCodedMsg = Convenc(bits);
    interleavedMsg = Interleave(convCodedMsg);
    QAMSymbols = DynamicQammod(interleavedMsg, cir); %  QAM映射
