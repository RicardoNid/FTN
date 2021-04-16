%  // ======================================================================
%  //  Jinan University
%  //  @Author: JiZhou CanyangXiong
%  //  @Last Modified time: 2021-03-05
%  //  @description: on=1,比特加载时的迭代
%  // ======================================================================

% (14) // =====================带有误码率的输出=====================================
% function [PerQAMtotal,PerQAMError,QAM_re_sum,pre_code_errors,decodedMsg_HD,number_of_error_HD]=iteration_alloc(decodedMsg_HD,OFDMParameters,tblen,iter,RXSymbols, cir)
%  // =====================不带误码率的输出=====================================
function decodedMsg_HD = iteration_alloc(decodedMsg_HD, OFDMParameters, tblen, RXSymbols, cir)
    FFTSize = OFDMParameters.FFTSize;
    OFDMSymbolNumber = OFDMParameters.OFDMSymbolNumber;
    DataCarrierPositions = OFDMParameters.DataCarrierPositions;
    SToPcol = OFDMParameters.SToPcol;

    convCodedMsg = Convenc(decodedMsg_HD);
    interleavedMsg = Interleave(convCodedMsg);

    %% mapping
    load('bitAllocSort.mat');
    load('BitAllocSum.mat');
    load('power_alloc.mat');
    rmsAlloc = [];
    ifftBlock = zeros(FFTSize, SToPcol);

    b = 1;

    for i = 1:length(bitAllocSort)

        if bitAllocSort(i) == 0
            QAMSymbols = 0;
            rmsAlloc = [0];
        else
            % mapping（自带的qammod)
            if bitAllocSort(i) ~= 0
                M = 2^bitAllocSort(i);
                modObj = modem.qammod('M', M, 'SymbolOrder', 'Gray', 'InputType', 'Bit');
                codeMsg1_per = OFDMSymbolNumber * bitAllocSort(i) * length(BitAllocSum{i}) * 2;
                codeMsg1_perloading = interleavedMsg(b:b + codeMsg1_per - 1, 1);
                b = codeMsg1_per + b;

                if bitAllocSort(i) == 3 % QAM8
                    QAM8 = [-1 - sqrt(3), -1 + 1i, -1 - 1i, 1i * (1 + sqrt(3)), -1i * (1 + sqrt(3)), 1 + 1i, 1 - 1i, 1 + sqrt(3)];
                    qam8bit = reshape(codeMsg1_perloading, bitAllocSort(i), [])';
                    qam8dec = bi2de(qam8bit, 'left-msb');
                    QAMSymbols = QAM8(qam8dec + 1);
                    QAMSymbols = QAMSymbols';
                else
                    QAMSymbols = modulate(modObj, codeMsg1_perloading);
                end

                rms_alloc = rms(QAMSymbols);
                rmsAlloc = [rmsAlloc; rms_alloc];

                if bitAllocSort(i) == 0
                    QAMSymbols = 0;
                else
                    QAMSymbols = QAMSymbols / rms_alloc;
                    QAMSymbols = reshape(QAMSymbols, length(BitAllocSum{i}), SToPcol);
                end

                carrierPosition = BitAllocSum{i};
                carrierPosition = carrierPosition + 2;
                ifftBlock(carrierPosition, :) = QAMSymbols;
            end

        end

    end

    load('power_alloc.mat');

    for i = 1:SToPcol
        ifftBlock(DataCarrierPositions, i) = ifftBlock(DataCarrierPositions, i) .* sqrt(power_alloc');
    end

    %% 结构简单，算ICI
    %% IFFT(zeros padding)
    OFDMSymbols = IFFT(ifftBlock);
    %% FFT(zeros padding)
    recovered = RecoverOFDMSymbols(OFDMSymbols, OFDMParameters);
    %% 计算ICI
    QAMSymbols_trans0 = ifftBlock(DataCarrierPositions, :);
    ICI = recovered - QAMSymbols_trans0;
    %% 从接收端的原始信号中去除ICI
    for i = 1:SToPcol % 接收信号进来没有进行功率分配 % RXSymbols为接收端FFT输出信号
        RXSymbols(DataCarrierPositions - 2, i) = RXSymbols(DataCarrierPositions - 2, i) .* sqrt(power_alloc');
    end

    dataQAMSymbols = RXSymbols - ICI;
    %% 除功率分配
    for i = 1:SToPcol
        dataQAMSymbols(DataCarrierPositions - 2, i) = dataQAMSymbols(DataCarrierPositions - 2, i) ./ sqrt(power_alloc');
    end

    %% receiver
    bitNumber_total = 0;
    number_of_error_total = 0;
    demodulated_HD = [];

    for i = 1:length(bitAllocSort)

        if bitAllocSort(i) ~= 0
            carrierPosition = BitAllocSum{i};
            QAM = reshape(dataQAMSymbols(carrierPosition, :), [], 1);
            QAM_re = QAM / rms(QAM) * rmsAlloc(i);
            % (15) // ======================================================================
            % 为了画最后的总体的星座图
            %         QAM_re_sum{i}= QAM_re;
            %  // ======================================================================
            %% Code properties(channel coding)
            constlen = 7;
            codegen = [171 133];
            tblen = 90;
            trellis = poly2trellis(constlen, codegen);
            %% de-mapping
            M = 2^bitAllocSort(i);

            if bitAllocSort(i) == 3 %QAM8
                carrierPosition = BitAllocSum{i};
                outPut = reshape(dataQAMSymbols(carrierPosition, :), [], 1);
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

            %% decisiong
            % Set up the demodulator object to perform hard decision demodulation
            demodulated_HD = [demodulated_HD, demodulatedMsg_HD];
        end

    end

    % (16) // ======================================================================
    %     load在CreateOFDMSymbols函数里on=1时保存的codeMsg,算每次迭代后的纠前误码率
    %     file = [ 'interleavedMsg' num2str(cir) '.mat'];
    %     interleavedMsg = cell2mat(struct2cell(load(file)));
    %     [pre_code_errors, pre_code_ber] = biterr(demodulated_HD', interleavedMsg);
    % % 为了画最后的总体的星座图
    %      save QAM_re_sum QAM_re_sum;
    %  // ======================================================================
    %% de-interleaving
    depth = 32;
    len = length(demodulated_HD) / depth;
    interleavedMsg = [];

    for k = 1:depth
        interleavedMsg = [interleavedMsg; demodulated_HD(len * (k - 1) + 1:len * k)];
    end

    demodulatedMsg_HD = interleavedMsg(:);
    %% viterbi decoder
    % Use the Viterbi decoder in hard decision mode(recvbits)
    file = ['bits' num2str(cir) '.mat'];
    bits = cell2mat(struct2cell(load(file)));
    decodedMsg_HD = vitdec(demodulatedMsg_HD, trellis, tblen, 'cont', 'hard');
    decodedMsg_HD = [decodedMsg_HD(tblen + 1:end); bits(length(bits) - tblen + 1:length(bits))];
    %% sendbits
    % (17)  // ======================================================================
    %     计算迭代后的误码率
    % c=1;
    % for i=1:length(bitAllocSort)
    %     if  bitAllocSort(i)~=0
    %         carrierPosition = BitAllocSum{i};
    %         bitNumber = OFDMSymbolNumber * length(carrierPosition) * bitAllocSort(i);
    %         bits_per = randint(bitNumber, 1, 2, OFDMParameters.Seed(cir));
    %         bitNumber_total =bitNumber_total+bitNumber;
    %         decodedMsg_HD_per = decodedMsg_HD(c:c+bitNumber-1,1);
    %         c = bitNumber+c;
    %         [nErrors_HD, ber_HD] = biterr(decodedMsg_HD_per, bits_per);
    %         % 把每种调制格式的错误数放一起，以及对应的比特总数
    %         PerQAMError(1,i) = nErrors_HD;
    %         PerQAMtotal(1,i) = length(bits_per);
    %
    %         if iter == iteration
    %             load('QAM_re_sum.mat');
    %             %   scatterplot(QAM_re_sum{i});
    %             %   title(['BER-MC = ', num2str(ber_HD)  '---NE= ', num2str(nErrors_HD) '---iteration', num2str(iter)]);
    %         end
    %         number_of_error_total = number_of_error_total+nErrors_HD;
    %     end
    % end
    % BER_MC_HD =number_of_error_total/bitNumber_total;
    % number_of_error_HD = number_of_error_total;
    %  // ======================================================================
