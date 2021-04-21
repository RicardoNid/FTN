function bits = Qamdemod(bitAllocated, QAMSymbols)

    if bitAllocated == 3;

        % QAM8的八个符号取值
        outPut = reshape(QAMSymbols, [], 1);
        outPut = outPut';
        QAM8 = [-1 - sqrt(3), -1 + 1i, -1 - 1i, 1i * (1 + sqrt(3)), -1i * (1 + sqrt(3)), 1 + 1i, 1 - 1i, 1 + sqrt(3)] ./ sqrt(3 + sqrt(3));
        [~, index] = min(abs(repmat(outPut, 8, 1) - repmat(transpose(QAM8), 1, length(outPut))));
        temp = de2bi(index - 1, 3, 'left-msb');
        bits = reshape(temp', 1, []);

    else
        M = 2^bitAllocated;
        modObj = modem.qammod('M', M, 'SymbolOrder', 'Gray', 'InputType', 'Bit');
        demodObj = modem.qamdemod(modObj);
        set(demodObj, 'DecisionType', 'Hard decision');
        bits = demodulate(demodObj, QAMSymbols);
    end
