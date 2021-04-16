%  // ======================================================================
%  //  Jinan University
%  //  @Author: JiZhou CanyangXiong
%  //  @Last Modified time: 2021-03-05
%  //  @description: �������ֲ�
%  // ======================================================================

% (18) // =====================���������ʵ����=====================================
% function [pre_code_errors,pre_code_ber,BER_MC_HD,decodedMsg_HD,number_of_error_HD]=iteration(decodedMsg_HD,OFDMParameters, tblen,i,recoveredSymbols_FDE, cir)
%  // =====================���������ʵ����=====================================
function decodedMsg_HD = iteration(decodedMsg_HD, OFDMParameters, tblen, i, recoveredSymbols_FDE, cir)
    FFTSize = OFDMParameters.FFTSize;
    BitsPerSymbolQAM = OFDMParameters.BitsPerSymbolQAM;
    CPLength = OFDMParameters.CPLength;
    DataCarrierPositions = OFDMParameters.DataCarrierPositions;
    OFDMPositions = OFDMParameters.OFDMPositions;
    SubcarriersNum = length(OFDMParameters.DataCarrierPositions);
    bitNumber = OFDMParameters.bitNumber;
    iterationT = OFDMParameters.iteration;
    SToPcol = OFDMParameters.SToPcol;
    %% channel coding
    % Code properties
    codedMsg = Convenc(decodedMsg_HD);

    %% interleaving
    depth = 32;
    codedMsg = reshape(codedMsg, depth, []);
    codeMsg = [];

    for k = 1:depth
        codeMsg = [codeMsg, codedMsg(k, :)];
    end

    codeMsg = codeMsg.';

    %% mapping
    M = 2^BitsPerSymbolQAM;
    modObj = modem.qammod('M', M, 'SymbolOrder', 'Gray', 'InputType', 'Bit');
    QAMSymbols = modulate(modObj, codeMsg);
    QAMSymbols = QAMSymbols / rms(QAMSymbols) * sqrt(10);
    QAMSymbols = reshape(QAMSymbols, length(DataCarrierPositions), SToPcol);

    %% �ṹ�򵥣���ICI
    S_HD = reshape(QAMSymbols, [], 1);
    %% IFFT(�ظ����˲�����zero padding
    ifftBlock = zeros(FFTSize, SToPcol);
    ifftBlock(DataCarrierPositions, :) = QAMSymbols;
    ifftBlock(FFTSize + 2 - DataCarrierPositions, :) = conj(ifftBlock(DataCarrierPositions, :));
    OFDMSymbols = ifft(ifftBlock);
    OFDMSymbols1 = OFDMSymbols(1:length(OFDMPositions), :);
    OFDMSymbols1 = [OFDMSymbols1(end - CPLength / 2 + 1:end, :); OFDMSymbols1; OFDMSymbols1(1:CPLength / 2, :)];
    OFDMSymbols = reshape(OFDMSymbols1, [], 1);
    %% FFT
    recovered = RecoverOFDMSymbols(OFDMSymbols, OFDMParameters);
    recoveredSymbols = reshape(recovered, [], 1);
    recoveredSymbols = recoveredSymbols / rms(recoveredSymbols) * sqrt(10); %16QAM�ǵø�
    %% ICI
    ICI = recoveredSymbols - S_HD;
    recoveredSymbols = recoveredSymbols_FDE - ICI;

    %% de-mapping
    M = 2^BitsPerSymbolQAM;
    modObj = modem.qammod('M', M, 'SymbolOrder', 'Gray', 'InputType', 'Bit');
    demodObj = modem.qamdemod(modObj);
    % Set up the demodulator object to perform hard decision demodulation
    set(demodObj, 'DecisionType', 'Hard decision');
    demodulatedMsg_HD = demodulate(demodObj, recoveredSymbols);
    demodulatedMsg_HD = demodulatedMsg_HD';

    depth = 32;
    len = length(demodulatedMsg_HD) / depth;
    codedMsg = [];

    for k = 1:depth
        codedMsg = [codedMsg; demodulatedMsg_HD(len * (k - 1) + 1:len * k)];
    end

    demodulatedMsg_HD = codedMsg(:);
    %% Use the Viterbi decoder in hard decision mode
    decodedMsg_HD = Vitdec(demodulatedMsg_HD);
    % (20) // ======================================================================
    %    ����������
    % % output
    % [nErrors_HD, ber_HD] = biterr(decodedMsg_HD, bits);
    % BER_MC_HD=ber_HD;
    % number_of_error_HD = nErrors_HD;
    % RecoveredSymbols = recoveredSymbols(:);
    % if cir == 20
    % scatterplot(RecoveredSymbols)
    % title([num2str(i),'iteration','BER-MC = ', num2str(BER_MC_HD)])
    % end
    %  // ======================================================================
    %% Calculate the optimal bit allocation
    if cir == 20

        if i == iterationT
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
            save './data/bitAllocSort' bitAllocSort;
            save './data/BitAllocSum' BitAllocSum;
            save './data/power_alloc' power_alloc;
        end

    end
