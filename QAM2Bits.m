function bits = QAM2Bits(QAMSymbols)

    % global DoInterleave
    % if DoInterleave == 1
    %     demodulated = DynamicQamdemod(QAMSymbols); % (动态)QAM解映射
    %     deinterleaved = Deinterleave(demodulated); % 解交织
    %     bits = Vitdec(deinterleaved); % 维特比译码
    % else
    %     demodulated = DynamicQamdemod(QAMSymbols); % (动态)QAM解映射
    %     bits = Vitdec(demodulated); % 维特比译码
    % end

    demodulated = DynamicQamdemod(QAMSymbols); % (动态)QAM解映射
    deinterleaved = Deinterleave(demodulated); % 解交织
    bits = Vitdec(deinterleaved); % 维特比译码
