function none = Alloc(recoveredSymbols)

    global SubcarriersNum

    file = ['./data/QAMSymbols_trans' num2str(20) '.mat']; %QAMSymbols_trans��CreateOFDMSymbols����on=0ʱ���棬������ÿ�����ز���SNR
    QAMSymbols_trans = cell2mat(struct2cell(load(file)));
    SendSymbols = QAMSymbols_trans * sqrt(10);
    SendSymbols = reshape(SendSymbols, 1, []);
    recoveredQAMSymbols = reshape(recoveredSymbols, 1, []);

    SNR = SNRLocation(recoveredQAMSymbols, SendSymbols);
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
