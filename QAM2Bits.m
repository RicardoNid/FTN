function bits = QAM2Bits(QAMSymbols)

    % global DoInterleave
    % if DoInterleave == 1
    %     demodulated = DynamicQamdemod(QAMSymbols); % (��̬)QAM��ӳ��
    %     deinterleaved = Deinterleave(demodulated); % �⽻֯
    %     bits = Vitdec(deinterleaved); % ά�ر�����
    % else
    %     demodulated = DynamicQamdemod(QAMSymbols); % (��̬)QAM��ӳ��
    %     bits = Vitdec(demodulated); % ά�ر�����
    % end

    demodulated = DynamicQamdemod(QAMSymbols); % (��̬)QAM��ӳ��
    deinterleaved = Deinterleave(demodulated); % �⽻֯
    bits = Vitdec(deinterleaved); % ά�ر�����
