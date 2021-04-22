function Demodulated = DynamicQamdemod(recovered)
    global On
    global BitsPerSymbolQAM;
    global RmsAlloc

    if On == 1
        load('./data/bitAllocSort.mat');
        load('./data/BitAllocSum.mat');

        % ����Ĵ����޷�������ط�����0����� ??
        Demodulated = [];

        for i = 1:length(bitAllocSort)

            bitAllocated = bitAllocSort(i);

            if bitAllocated ~= 0
                carrierPosition = BitAllocSum{i};
                QAM = reshape(recovered(carrierPosition, :), [], 1);
                demodulated = Qamdemod(bitAllocated, QAM);
                Demodulated = [Demodulated, demodulated];
            end

        end

    else
        % �˴�����Ҳ�ǲ���Ҫ�� ??
        recovered = recovered / rms(recovered) * RmsAlloc(4);
        Demodulated = Qamdemod(BitsPerSymbolQAM, recovered);
    end
