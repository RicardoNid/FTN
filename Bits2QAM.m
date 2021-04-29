function QAMSymbols = Bits2QAM(bits)
    
    % global DoInterleave
    % if DoInterleave == 1
    %     convCodedBits = Convenc(bits); % �������
    %     interleavedBits = Interleave(convCodedBits); % ��֯
    %     QAMSymbols = DynamicQammod(interleavedBits); % (��̬)QAMӳ��
    % else
    %     convCodedBits = Convenc(bits); % �������
    %     QAMSymbols = DynamicQammod(convCodedBits); % (��̬)QAMӳ��
    % end

    convCodedBits = Convenc(bits); % �������
    interleavedBits = Interleave(convCodedBits); % ��֯
    QAMSymbols = DynamicQammod(interleavedBits); % (��̬)QAMӳ��
