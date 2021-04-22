function bits = QAM2Bits(QAMSymbols)
    demodulated = DynamicQamdemod(QAMSymbols);
    deinterleaved = Deinterleave(demodulated);
    deinterleaved = deinterleaved(:); % ??
    bits = Vitdec(deinterleaved);
