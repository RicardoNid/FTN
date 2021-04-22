function QAMSymbols = Bits2QAM(bits)
    convCodedMsg = Convenc(bits); % 卷积编码
    interleavedMsg = Interleave(convCodedMsg); % 交织
    QAMSymbols = DynamicQammod(interleavedMsg); %  (动态)QAM映射
