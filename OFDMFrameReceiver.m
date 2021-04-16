%  // ======================================================================
%  //  Jinan University
%  //  @Author: JiZhou CanyangXiong
%  //  @Last Modified time: 2021-03-05
%  //  @description: 接收端DSP
%  // ======================================================================

% (4) // =====================带有误码率的输出=====================================
% function  [PerQAMtotal,PerQAMError,QAM_re_sum,pre_code_errors,number_of_error] = OFDMFrameReceiver(recvOFDMFrame, OFDMParameters, cir)
%  // =====================不带误码率的输出=====================================
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
    % 计算BER时，产生sendbits的时候需要
    % OFDMSymbolNumber = OFDMParameters.OFDMSymbolNumber;
    %  // ======================================================================
    %% FDE
    preamble = recvOFDMFrame(1:preambleNumber * (FFTSize + CPLength));
    H = ChannelEstimationByPreamble(preamble, OFDMParameters);
    tap = 20;
    H = smooth(H, tap);
    % (6) // ======================================================================
    %    估计出的信道
    % figure;
    % plot(20*log10(abs(H)));
    %  // ======================================================================
    recvOFDMSignal = recvOFDMFrame(preambleNumber * (FFTSize + CPLength) + 1:end);
    [recovered, recvOFDMSignal] = RecoverOFDMSymbolsWithPilot(recvOFDMSignal, OFDMParameters, H);

    % 除对应功率
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
        %     计算误码率时需要
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
        bits = ones(bitNumber, 1);
        decodedMsg_HD = vitdec(demodulatedMsg_HD, trellis, tblen, 'cont', 'hard');
        decodedMsg_HD = [decodedMsg_HD(tblen + 1:end); bits(length(bits) - tblen + 1:length(bits))];

        % iteration
        for iter = 1:iterationT
            % (9) // =====================带有误码率的输出=====================================
            %   [PerQAMtotal,PerQAMError,QAM_re_sum,pre_code_errors,decodedMsg_HD,number_of_error_HD]=iteration_alloc(decodedMsg_HD,OFDMParameters,tblen,iter,recovered, cir);
            %  // =====================不带误码率的输出=====================================
            decodedMsg_HD = iteration_alloc(decodedMsg_HD, OFDMParameters, tblen, recovered, cir);
        end

        % (10) // ==========================================================
        %     将错误数输出，在OFDM_test中算误码率
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
        bits = ones(bitNumber, 1);
        decodedMsg_HD = [decodedMsg_HD(tblen + 1:end); bits(length(bits) - tblen + 1:length(bits))];
        % (11) // ======================================================================
        %    计算迭代前的误码率
        %     [nErrors_HD, ber_HD] = biterr(decodedMsg_HD, bits);
        %     number_of_error=nErrors_HD;
        %     BER_MC=ber_HD;
        %  // ======================================================================

        %iteration
        for i = 1:iterationT
            % (12) // =====================带有误码率的输出=====================================
            %         [pre_code_errors,pre_code_ber,BER_MC_HD,decodedMsg_HD,number_of_error_HD]= iteration(decodedMsg_HD,OFDMParameters ,tblen,i,recoveredSymbols_FDE, cir);
            %  // =====================不带误码率的输出=====================================
            decodedMsg_HD = iteration(decodedMsg_HD, OFDMParameters, tblen, i, recoveredSymbols_FDE, cir);
        end

        %  // ======================================================================
        % (13) 带有迭代后的误码率的输出
        %     BER_MC = BER_MC_HD;
        %     BER_pre = pre_code_ber;
        %     number_of_error = number_of_error_HD;
        %
        %     %因为on=1的时候，需要输出这几个变量，所以on=0的时候，也要添加这几个输出,为了计算on=1时的星座图和不同调制格式的误码率
        %     QAM_re_sum=0;
        %     PerQAMError=0;
        %     PerQAMtotal=0;
        %  // ======================================================================
        %%
    end
