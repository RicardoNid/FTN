%  // ======================================================================
%  //  Jinan University
%  //  @Author: JiZhou CanyangXiong
%  //  @Last Modified time: 2021-03-05
%  //  @description: ���ն�DSP
%  // ======================================================================

% (4) // =====================���������ʵ����=====================================
% function  [PerQAMtotal,PerQAMError,QAM_re_sum,pre_code_errors,number_of_error] = OFDMFrameReceiver(recvOFDMFrame, OFDMParameters, cir)
%  // =====================���������ʵ����=====================================
function [decodedMsg_HD] = OFDMFrameReceiver(recvOFDMFrame, OFDMParameters, cir)
    on = OFDMParameters.on;
    iterationT = OFDMParameters.iteration;
    CPLength = OFDMParameters.CPLength;
    BitsPerSymbolQAM = OFDMParameters.BitsPerSymbolQAM;
    DataCarrierPositions = OFDMParameters.DataCarrierPositions;
    preambleNumber = OFDMParameters.PreambleNumber;
    bitNumber = OFDMParameters.bitNumber;
    SToPcol = OFDMParameters.SToPcol;
    FFTSize = OFDMParameters.FFTSize;
    % (5) // ======================================================================
    % ����BERʱ������sendbits��ʱ����Ҫ
    % OFDMSymbolNumber = OFDMParameters.OFDMSymbolNumber;
    %  // ======================================================================
    %% FDE
    preamble = recvOFDMFrame(1:preambleNumber * (FFTSize + CPLength));
    H = ChannelEstimationByPreamble(preamble, OFDMParameters);
    tap = 20;
    H = smooth(H, tap);
    % (6) // ======================================================================
    %    ���Ƴ����ŵ�
    % figure;
    % plot(20*log10(abs(H)));
    %  // ======================================================================
    recvOFDMSignal = recvOFDMFrame(preambleNumber * (FFTSize + CPLength) + 1:end);
    [recovered, recvOFDMSignal] = RecoverOFDMSymbolsWithPilot(recvOFDMSignal, OFDMParameters, H);

    % ����Ӧ����
    if on == 1
        load('power_alloc.mat');

        for i = 1:SToPcol
            recovered(DataCarrierPositions - 2, i) = recovered(DataCarrierPositions - 2, i) ./ sqrt(power_alloc');
        end

    else
        recoveredSymbols = reshape(recovered, [], 1);
    end

    if on == 1
        %% bit loading %%
        load('bitAllocSort.mat');
        load('BitAllocSum.mat');
        file = ['rmsAlloc' num2str(cir) '.mat'];
        rmsAlloc = cell2mat(struct2cell(load(file)));
        % (7) // ======================================================================
        %     ����������ʱ��Ҫ
        %     bitNumber_total =0;
        %     number_of_error_total = 0;
        %  // ======================================================================
        demodulated_HD = [];

        for i = 1:length(bitAllocSort)

            if bitAllocSort(i) ~= 0
                carrierPosition = BitAllocSum{i};
                QAM = reshape(recovered(carrierPosition, :), [], 1);
                QAM_re = QAM / rms(QAM) * rmsAlloc(i);
                % Code properties(channel coding)
                constlen = 7;
                codegen = [171 133];
                tblen = 90;
                trellis = poly2trellis(constlen, codegen);
                % de-mapping
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

        % de-interleaving
        depth = 32;
        len = length(demodulated_HD) / depth;
        codeMsg = [];

        for k = 1:depth
            codeMsg = [codeMsg; demodulated_HD(len * (k - 1) + 1:len * k)];
        end

        demodulatedMsg_HD = codeMsg(:);

        % viterbi decoder
        % Use the Viterbi decoder in hard decision mode(recvbits)
        file = ['bits' num2str(cir) '.mat'];
        bits = cell2mat(struct2cell(load(file)));
        decodedMsg_HD = vitdec(demodulatedMsg_HD, trellis, tblen, 'cont', 'hard');
        decodedMsg_HD = [decodedMsg_HD(tblen + 1:end); bits(length(bits) - tblen + 1:length(bits))];

        % (8) // ======================================================================
        %     �������ǰ��������
        %     % sendbits
        %     c=1;
        %     for i=1:length(bitAllocSort)
        %         if bitAllocSort(i)~=0
        %             carrierPosition = BitAllocSum{i};
        %             bitNumber = OFDMSymbolNumber * length(carrierPosition) * bitAllocSort(i);
        %             bits_per = randint(bitNumber, 1, 2, OFDMParameters.Seed(cir));
        %             bitNumber_total =bitNumber_total+bitNumber;
        %             decodedMsg_HD_per = decodedMsg_HD(c:c+bitNumber-1,1);
        %             c = bitNumber+c;
        %             [nErrors_HD, ber_HD] = biterr(decodedMsg_HD_per, bits_per);
        %             BER_MC=ber_HD;
        %             number_of_error=nErrors_HD;
        %             number_of_error_total = number_of_error_total+nErrors_HD;
        %         end
        %     end
        %     BER_MC =number_of_error_total/bitNumber_total;
        % %  // ======================================================================

        % iteration
        for iter = 1:iterationT
            % (9) // =====================���������ʵ����=====================================
            %   [PerQAMtotal,PerQAMError,QAM_re_sum,pre_code_errors,decodedMsg_HD,number_of_error_HD]=iteration_alloc(decodedMsg_HD,OFDMParameters,tblen,iter,recovered, cir);
            %  // =====================���������ʵ����=====================================
            decodedMsg_HD = iteration_alloc(decodedMsg_HD, OFDMParameters, tblen, recovered, cir);
        end

        % (10) // ==========================================================
        %     ���������������OFDM_test����������
        %      number_of_error = number_of_error_HD;
        %  // ==========================================================
    else
        %% cal %%
        recoveredSymbols = recoveredSymbols / rms(recoveredSymbols) * sqrt(10);
        recoveredSymbols_FDE = recoveredSymbols;
        % Code properties(channel coding)
        constlen = 7;
        codegen = [171 133];
        tblen = 90;
        trellis = poly2trellis(constlen, codegen);

        % de-mapping
        M = 2^BitsPerSymbolQAM;
        modObj = modem.qammod('M', M, 'SymbolOrder', 'Gray', 'InputType', 'Bit');
        demodObj = modem.qamdemod(modObj);

        % decisiong
        % Set up the demodulator object to perform hard decision demodulation
        set(demodObj, 'DecisionType', 'Hard decision');
        demodulatedMsg_HD = demodulate(demodObj, recoveredSymbols);
        demodulatedMsg_HD = demodulatedMsg_HD';

        % de-interleaving
        depth = 32;
        len = length(demodulatedMsg_HD) / depth;
        codeMsg = [];

        for k = 1:depth
            codeMsg = [codeMsg; demodulatedMsg_HD(len * (k - 1) + 1:len * k)];
        end

        demodulatedMsg_HD = codeMsg(:);

        % viterbi decoder
        % Use the Viterbi decoder in hard decision mode
        decodedMsg_HD = vitdec(demodulatedMsg_HD, trellis, tblen, 'cont', 'hard');
        bits = randint(1, bitNumber, 2, OFDMParameters.Seed(cir));
        bits = bits.'; %����ת����Ϊ��ע�͵��Ĳ��֣��������ʣ����ֻ��FPGA������Ҫת�ã�ֻ֪��bits�ĳ��ȾͿ�����
        decodedMsg_HD = [decodedMsg_HD(tblen + 1:end); bits(length(bits) - tblen + 1:length(bits))];
        % (11) // ======================================================================
        %    �������ǰ��������
        %     [nErrors_HD, ber_HD] = biterr(decodedMsg_HD, bits);
        %     number_of_error=nErrors_HD;
        %     BER_MC=ber_HD;
        %  // ======================================================================

        %iteration
        for i = 1:iterationT
            % (12) // =====================���������ʵ����=====================================
            %         [pre_code_errors,pre_code_ber,BER_MC_HD,decodedMsg_HD,number_of_error_HD]= iteration(decodedMsg_HD,OFDMParameters ,tblen,i,recoveredSymbols_FDE, cir);
            %  // =====================���������ʵ����=====================================
            decodedMsg_HD = iteration(decodedMsg_HD, OFDMParameters, tblen, i, recoveredSymbols_FDE, cir);
        end

        %  // ======================================================================
        % (13) ���е�����������ʵ����
        %     BER_MC = BER_MC_HD;
        %     BER_pre = pre_code_ber;
        %     number_of_error = number_of_error_HD;
        %
        %     %��Ϊon=1��ʱ����Ҫ����⼸������������on=0��ʱ��ҲҪ�����⼸�����,Ϊ�˼���on=1ʱ������ͼ�Ͳ�ͬ���Ƹ�ʽ��������
        %     QAM_re_sum=0;
        %     PerQAMError=0;
        %     PerQAMtotal=0;
        %  // ======================================================================
        %%
    end