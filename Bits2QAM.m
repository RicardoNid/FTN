function QAMSymbols = Bits2QAM(bits)
    convCodedMsg = Convenc(bits); % �������
    interleavedMsg = Interleave(convCodedMsg); % ��֯
    QAMSymbols = DynamicQammod(interleavedMsg); %  (��̬)QAMӳ��
