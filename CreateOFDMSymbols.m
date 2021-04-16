%  // ======================================================================
%  //  Jinan University
%  //  @Author: JiZhou CanyangXiong
%  //  @Last Modified time: 2021-03-05
%  //  @description: 生成FTN符号
%  // ======================================================================
function [OFDMSymbols, bitsPerFrame] = CreateOFDMSymbols(OFDMParameters, cir)
    on = OFDMParameters.on;
    FFTSize = OFDMParameters.FFTSize;
    OFDMPositions = OFDMParameters.OFDMPositions;
    CPLength = OFDMParameters.CPLength;
    OFDMSymbolNumber = OFDMParameters.OFDMSymbolNumber;
    BitsPerSymbolQAM = OFDMParameters.BitsPerSymbolQAM;
    DataCarrierPositions = OFDMParameters.DataCarrierPositions;
    bitNumber = OFDMParameters.bitNumber;
    SToPcol = OFDMParameters.SToPcol;

    if on == 1
        %% bit loading %%
        load('bitAllocSort.mat');
        load('BitAllocSum.mat');
        load('power_alloc.mat');
        rmsAlloc = [];
        bits = [];
        ifftBlock = zeros(FFTSize, SToPcol);

        bits = randint(bitNumber, 1, 2, OFDMParameters.Seed(cir));
        % for i = 1:length(bitAllocSort)
        %     carrierPosition = BitAllocSum{i};
        %     bitNumber = OFDMSymbolNumber * length(carrierPosition) * bitAllocSort(i);
        %     bits_per = randint(bitNumber, 1, 2, OFDMParameters.Seed(cir));
        %     bits = [bits; bits_per];
        % end

        bitsPerFrame = bits;
        %在OFDMFrameReceiver中vitdec后需要用到这个bits
        file = ['bits' num2str(cir) '.mat'];
        save(file, 'bits');

        % Channel Coding
        convCodedMsg = Convenc(bits);
        % Interleaving
        interleavedMsg = Interleave(convCodedMsg);

        % Qammod 比特分配后,面向不同的子载波,有不同的M
        b = 1;

        for i = 1:length(bitAllocSort)

            if bitAllocSort(i) == 0
                QAMSymbols = 0;
                rmsAlloc = 0;
            else
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
                QAMSymbols = QAMSymbols / rms_alloc;
                QAMSymbols = reshape(QAMSymbols, length(BitAllocSum{i}), SToPcol);
            end

            carrierPosition = BitAllocSum{i};
            carrierPosition = carrierPosition + 2;
            ifftBlock(carrierPosition, :) = QAMSymbols;
        end

        %OFDMFrameReceiver是需要除相应的rms的，所以这个需要存起来
        file = ['rmsAlloc' num2str(cir) '.mat'];
        save(file, 'rmsAlloc');

        % 功率加载
        for i = 1:SToPcol
            ifftBlock(DataCarrierPositions, i) = ifftBlock(DataCarrierPositions, i) .* sqrt(power_alloc');
        end

        %%
    else
        %% cal %%
        bits = randint(bitNumber, 1, 2, OFDMParameters.Seed(cir)); %每个cir对应的种子数不一样，因为子帧数据要求不一样
        bitsPerFrame = bits;
        % Code properties(channel coding)
        convCodedMsg = Convenc(bits);
        % Interleaving
        interleavedMsg = Interleave(convCodedMsg);

        % mapping（自带的qammod)
        M = 2^BitsPerSymbolQAM;
        modObj = modem.qammod('M', M, 'SymbolOrder', 'Gray', 'InputType', 'Bit');
        QAMSymbols = modulate(modObj, interleavedMsg);
        QAMSymbols = QAMSymbols / rms(QAMSymbols);

        % 在iteration函数里，最后一帧最后一次迭代算比特分配的时候，需要用QAMSymbols_trans去算SNR，根据SNR应用Chow，才能得到比特功率分配
        file = ['QAMSymbols_trans' num2str(cir) '.mat'];
        save(file, 'QAMSymbols');
        QAMSymbols = reshape(QAMSymbols, length(DataCarrierPositions), SToPcol);
        ifftBlock = zeros(FFTSize, SToPcol);
        ifftBlock(DataCarrierPositions, :) = QAMSymbols;
    end

    OFDMSymbols = IFFT(ifftBlock);
