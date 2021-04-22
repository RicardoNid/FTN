function Demodulated = DynamicQamdemod(recovered)
    global On
    global BitsPerSymbolQAM;
    global RmsAlloc

    if On == 1
        %% bit loading %%
        load('./data/bitAllocSort.mat');
        load('./data/BitAllocSum.mat');
        demodulated_HD = [];

        for i = 1:length(bitAllocSort)

            if bitAllocSort(i) ~= 0
                carrierPosition = BitAllocSum{i};
                QAM = reshape(recovered(carrierPosition, :), [], 1);
                QAM_re = QAM / rms(QAM) * RmsAlloc(bitAllocSort(i));

                M = 2^bitAllocSort(i);

                if bitAllocSort(i) == 3 %QAM8
                    carrierPosition = BitAllocSum{i};
                    outPut = reshape(recovered(carrierPosition, :), [], 1);
                    outPut = outPut';
                    QAM8 = [-1 - sqrt(3), -1 + 1i, -1 - 1i, 1i * (1 + sqrt(3)), -1i * (1 + sqrt(3)), 1 + 1i, 1 - 1i, 1 + sqrt(3)] ./ sqrt(3 + sqrt(3));
                    [~, index] = min(abs(repmat(outPut, 8, 1) - repmat(transpose(QAM8), 1, length(outPut))));
                    temp = de2bi(index - 1, 3, 'left-msb');
                    demodulatedMsg_HD = reshape(temp', 1, []);
                else
                    modObj = modem.qammod('M', M, 'SymbolOrder', 'Gray', 'InputType', 'Bit');
                    demodObj = modem.qamdemod(modObj);
                    set(demodObj, 'DecisionType', 'Hard decision');
                    demodulatedMsg_HD = demodulate(demodObj, QAM_re);
                    demodulatedMsg_HD = demodulatedMsg_HD';
                end

                % decisiong
                % Set up the demodulator object to perform hard decision demodulation
                demodulated_HD = [demodulated_HD, demodulatedMsg_HD];
            end

        end

        Demodulated = demodulated_HD;
    else
        recovered = recovered / rms(recovered) * RmsAlloc(4);

        M = 2^BitsPerSymbolQAM;
        modObj = modem.qammod('M', M, 'SymbolOrder', 'Gray', 'InputType', 'Bit');
        demodObj = modem.qamdemod(modObj);

        set(demodObj, 'DecisionType', 'Hard decision');
        demodulatedMsg_HD = demodulate(demodObj, recovered);
        Demodulated = demodulatedMsg_HD';
    end
