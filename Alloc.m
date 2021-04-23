function none = Alloc(recoveredSymbols)

    % ��ʼ����������,����gap��chow�㷨��Ŀ��,��Ϊ��������;��������Ϊ���������
    global BER
    global SER
    global Gap
    global Miu

    %% ���ط�������������һ�ε��������Ĳ�ֵQAM���ź���ʵQAM����
    % ʵ��ʵ����,���ط�����ù̶�����֡,��Ӧ��QAM����,ͬʱ�洢�ڽ��ջ��뷢���

    load './data/QAMSymbolsForAlloc'
    SNR = SNRLocation(recoveredSymbols, QAMSymbolsForAlloc); % SNR�ǶԱ���ʵQAM���ź͵�����ָ���QAM���ŵõ�

    % ���ε���
    [bits_allo, power_allo, total_bits] = chow_algo_all(SNR, Gap);
    display('first time done')

    % ��Ϊ�������õ�gap���趨��BER����������һ�������ŵģ�ͨ������ķ�ʽ���ҵ���SNR����֧�ֵ����ŵ�gap
    % û���κα��ر�����ʱ,��flag = 1�ķ������Ŀ��
    if total_bits == 0
        display('mode 1')
        flag = 1;

        while (BER > 0) && (BER < 0.2) && (total_bits == 0)
            BER = BER + flag * Miu;
            SER = 1 - (1 - BER)^4;
            Gap = 1/3 * (qfuncinv(SER / 4))^2;
            bits_alloc_record = bits_allo;
            power_alloc_record = power_allo;
            [bits_allo, power_allo, total_bits] = chow_algo_all(SNR, Gap);
        end

    end

    % �б��ر�����ʱ,��flag = 1�ķ������Ŀ��
    if total_bits ~= 0
        display('mode 2')
        flag = -1;

        while (BER > 0) && (BER < 0.2) && (total_bits > 0)
            BER = BER + flag * Miu;
            SER = 1 - (1 - BER)^4;
            Gap = 1/3 * (qfuncinv(SER / 4))^2;
            bits_alloc_record = bits_allo;
            power_alloc_record = power_allo;
            [bits_allo, power_allo, total_bits] = chow_algo_all(SNR, Gap);
        end

    end

    bits_alloc = bits_alloc_record;
    power_alloc = power_alloc_record;
    power_alloc = power_alloc';

    [bitAllocSort, BitAllocSum] = bits_alloc_position_sum(bits_alloc');
    bitAlloc = bits_alloc;
    save './data/bitAlloc' bitAlloc
    save './data/bitAllocSort' bitAllocSort;
    save './data/BitAllocSum' BitAllocSum;
    save './data/power_alloc' power_alloc;
