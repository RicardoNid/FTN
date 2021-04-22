function QAMSymbols = Bits2QAM(bits)
    global CurrentFrame
    convCodedMsg = Convenc(bits);
    interleavedMsg = Interleave(convCodedMsg);
    QAMSymbols = DynamicQammod(interleavedMsg, CurrentFrame); %  QAM映射
