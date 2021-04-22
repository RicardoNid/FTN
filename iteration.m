function decodedMsg_HD = iteration(decodedMsg_HD, OFDMParameters, tblen, i, recoveredSymbols_FDE, cir)
    FFTSize = OFDMParameters.FFTSize;
    BitsPerSymbolQAM = OFDMParameters.BitsPerSymbolQAM;
    CPLength = OFDMParameters.CPLength;
    DataCarrierPositions = OFDMParameters.DataCarrierPositions;
    OFDMPositions = OFDMParameters.OFDMPositions;
    SubcarriersNum = length(OFDMParameters.DataCarrierPositions);
    iterationT = OFDMParameters.iteration;
    SToPcol = OFDMParameters.SToPcol;

    codedMsg = Convenc(decodedMsg_HD);
    codeMsg = Interleave(codedMsg);

    %% mapping
    M = 2^BitsPerSymbolQAM;
    modObj = modem.qammod('M', M, 'SymbolOrder', 'Gray', 'InputType', 'Bit');
    QAMSymbols = modulate(modObj, codeMsg);
    QAMSymbols = QAMSymbols / rms(QAMSymbols) * sqrt(10);
    QAMSymbols = reshape(QAMSymbols, length(DataCarrierPositions), SToPcol);

    %% 结构简单，算ICI
    S_HD = reshape(QAMSymbols, [], 1);
    %% IFFT(重复发端操作）zero padding
    ifftBlock = zeros(FFTSize, SToPcol);
    ifftBlock(DataCarrierPositions, :) = QAMSymbols;
    ifftBlock(FFTSize + 2 - DataCarrierPositions, :) = conj(ifftBlock(DataCarrierPositions, :));
    OFDMSymbols = ifft(ifftBlock);
    OFDMSymbols1 = OFDMSymbols(1:length(OFDMPositions), :);
    OFDMSymbols1 = [OFDMSymbols1(end - CPLength / 2 + 1:end, :); OFDMSymbols1; OFDMSymbols1(1:CPLength / 2, :)];
    OFDMSymbols = reshape(OFDMSymbols1, [], 1);
    %% FFT
    recovered = FFT(OFDMSymbols);
    recoveredSymbols = reshape(recovered, [], 1);
    recoveredSymbols = recoveredSymbols / rms(recoveredSymbols) * sqrt(10); %16QAM记得改
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

    codedMsg = Deinterleave(demodulatedMsg_HD);

    demodulatedMsg_HD = codedMsg(:);
    %% Use the Viterbi decoder in hard decision mode
    decodedMsg_HD = Vitdec(demodulatedMsg_HD);

    if cir == 20

        if i == iterationT
            file = ['./data/QAMSymbols_trans' num2str(cir) '.mat']; %QAMSymbols_trans由CreateOFDMSymbols函数on=0时保存，用来算每个子载波的SNR
            QAMSymbols_trans = cell2mat(struct2cell(load(file)));
            SendSymbols = QAMSymbols_trans * sqrt(10);
            SendSymbols = reshape(SendSymbols, 1, []);
            recoveredQAMSymbols = reshape(recoveredSymbols, 1, []);

            SNR = SNRLocation(recoveredQAMSymbols, SendSymbols, OFDMParameters);
            %         title([num2str(i),'iteration','SNRPersubcarrier '])

            BER = 1e-3; %误码率
            SER = 1 - (1 - BER)^4;
            gap = 1/3 * (qfuncinv(SER / 4))^2;
            target_bit = 4;
            Rbit = round(target_bit * SubcarriersNum);
            miu = 1e-5;
            [bits_allo, power_allo, total_bits] = chow_algo_all(SNR, SubcarriersNum, gap, Rbit);

            % 因为上面设置的gap由设定的BER得来，但不一定是最优的，通过下面的方式，找到该SNR所能支持的最优的gap
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
        end

    end
