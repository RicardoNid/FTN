function QAMSymbols = Qammod(bitAllocated, bits)

    if bitAllocated == 3;
        % QAM8的八个符号取值
        QAM8 = [-1 - sqrt(3), -1 + 1i, -1 - 1i, 1i * (1 + sqrt(3)), -1i * (1 + sqrt(3)), 1 + 1i, 1 - 1i, 1 + sqrt(3)];
        qam8bit = reshape(bits, 3, [])';
        qam8dec = bi2de(qam8bit, 'left-msb');
        % qam8dec + 1取值1-8
        QAMSymbols = QAM8(qam8dec + 1);
        QAMSymbols = QAMSymbols';
    else
        M = 2^bitAllocated;
        modObj = modem.qammod('M', M, 'SymbolOrder', 'Gray', 'InputType', 'Bit');
        QAMSymbols = modulate(modObj, bits);
    end
