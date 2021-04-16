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
    global tblen
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
        load('./data/power_alloc.mat');

        for i = 1:SToPcol
            recovered(DataCarrierPositions - 2, i) = recovered(DataCarrierPositions - 2, i) ./ sqrt(power_alloc');
        end

    else
        recoveredSymbols = reshape(recovered, [], 1);
    end

    if on == 1
        %% bit loading %%
        load('./data/bitAllocSort.mat');
        load('./data/BitAllocSum.mat');
        file = ['./data/rmsAlloc' num2str(cir) '.mat'];
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

        decodedMsg_HD = Vitdec(demodulatedMsg_HD);

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
        decodedMsg_HD = Vitdec(demodulatedMsg_HD);
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
        %     %��Ϊon=1��ʱ����Ҫ����⼸������������on=0��ʱ��ҲҪ����⼸�����,Ϊ�˼���on=1ʱ������ͼ�Ͳ�ͬ���Ƹ�ʽ��������
        %     QAM_re_sum=0;
        %     PerQAMError=0;
        %     PerQAMtotal=0;
        %  // ======================================================================
        %%
    end
