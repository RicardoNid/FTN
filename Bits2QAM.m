function QAMSymbols = Bits2QAM(bits)
    
    % global DoInterleave
    % if DoInterleave == 1
    %     convCodedBits = Convenc(bits); % 卷积编码
    %     interleavedBits = Interleave(convCodedBits); % 交织
    %     QAMSymbols = DynamicQammod(interleavedBits); % (动态)QAM映射
    % else
    %     convCodedBits = Convenc(bits); % 卷积编码
    %     QAMSymbols = DynamicQammod(convCodedBits); % (动态)QAM映射
    % end

    convCodedBits = Convenc(bits); % 卷积编码
    interleavedBits = Interleave(convCodedBits); % 交织
    QAMSymbols = DynamicQammod(interleavedBits); % (动态)QAM映射
