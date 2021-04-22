function decodedMsg_HD = iteration(decodedMsg_HD, OFDMParameters, tblen, i, recoveredSymbols_FDE, cir)
    global RmsAlloc
    global FFTSize
    global SToPcol
    global DataCarrierPositions
    global BitsPerSymbolQAM
    global Iteration
    global SubcarriersNum

    % �ظ������

    QAMSymbols = Bits2QAM(decodedMsg_HD, cir);

    S_HD = QAMSymbols;
    S_HD = reshape(S_HD, [], 1); % ��QAMSymbols��·��ȥ

    ifftBlock = zeros(FFTSize, SToPcol);
    ifftBlock(DataCarrierPositions, :) = QAMSymbols;

    OFDMSymbols = IFFT(ifftBlock);
    recovered = FFT(OFDMSymbols);

    % �����
    recoveredSymbols = reshape(recovered, [], 1);
    ICI = recoveredSymbols - S_HD;
    recoveredSymbols = recoveredSymbols_FDE - ICI;

    decodedMsg_HD = QAM2Bits(recoveredSymbols);

    % �˴�����Ҳ�ǲ���Ҫ��
    recoveredSymbols = recoveredSymbols * RmsAlloc(4);

    if cir == 20

        if i == Iteration
            file = ['./data/QAMSymbols_trans' num2str(cir) '.mat']; %QAMSymbols_trans��CreateOFDMSymbols����on=0ʱ���棬������ÿ�����ز���SNR
            QAMSymbols_trans = cell2mat(struct2cell(load(file)));
            SendSymbols = QAMSymbols_trans * sqrt(10);
            SendSymbols = reshape(SendSymbols, 1, []);
            recoveredQAMSymbols = reshape(recoveredSymbols, 1, []);

            SNR = SNRLocation(recoveredQAMSymbols, SendSymbols, OFDMParameters);
            %         title([num2str(i),'iteration','SNRPersubcarrier '])

            BER = 1e-3; %������
            SER = 1 - (1 - BER)^4;
            gap = 1/3 * (qfuncinv(SER / 4))^2;
            target_bit = 4;
            Rbit = round(target_bit * SubcarriersNum);
            miu = 1e-5;
            [bits_allo, power_allo, total_bits] = chow_algo_all(SNR, SubcarriersNum, gap, Rbit);

            % ��Ϊ�������õ�gap���趨��BER����������һ�������ŵģ�ͨ������ķ�ʽ���ҵ���SNR����֧�ֵ����ŵ�gap
            if total_bits == 0
                flag = 1;

                while (BER > 0) && (BER < 0.2) && (total_bits == 0)
                    BER = BER + flag * miu;
                    SER = 1 - (1 - BER)^4;
                    gap = 1/3 * (qfuncinv(SER / 4))^2;
                    bits_alloc_record = bits_allo;
                    power_alloc_record = power_allo;
                    [bits_allo, power_allo, total_bits] = chow_algo_all(SNR, SubcarriersNum, gap, Rbit);
                end

            end

            if total_bits ~= 0
                flag = -1;

                while (BER > 0) && (BER < 0.2) && (total_bits > 0)
                    BER = BER + flag * miu;
                    SER = 1 - (1 - BER)^4;
                    gap = 1/3 * (qfuncinv(SER / 4))^2;
                    bits_alloc_record = bits_allo;
                    power_alloc_record = power_allo;
                    [bits_allo, power_allo, total_bits] = chow_algo_all(SNR, SubcarriersNum, gap, Rbit);
                end

            end

            bits_alloc = bits_alloc_record;
            power_alloc = power_alloc_record;
            power_alloc = power_alloc';

            [bitAllocSort, BitAllocSum] = bits_alloc_position_sum(bits_alloc', SubcarriersNum);
            bitAlloc = bits_alloc;
            save './data/bitAlloc' bitAlloc
            save './data/bitAllocSort' bitAllocSort;
            save './data/BitAllocSum' BitAllocSum;
            save './data/power_alloc' power_alloc;
            % Alloc();
        end

    end
