%  // ======================================================================
%  //  Jinan University
%  //  @Author: JiZhou CanyangXiong
%  //  @Last Modified time: 2021-03-05
%  //  @description: 生成FTN符号
%  // ======================================================================
function [OFDMSymbols, bitsPerFrame] = CreateOFDMSymbols(OFDMParameters, cir)
    on = OFDMParameters.on;
    FFTSize = OFDMParameters.FFTSize;
    OFDMSymbolNumber = OFDMParameters.OFDMSymbolNumber;
    BitsPerSymbolQAM = OFDMParameters.BitsPerSymbolQAM;
    DataCarrierPositions = OFDMParameters.DataCarrierPositions;
    SToPcol = OFDMParameters.SToPcol;

    %% Random BitGen
    bits = BitGen(cir);
    bitsPerFrame = bits;

    convCodedMsg = Convenc(bits);
    interleavedMsg = Interleave(convCodedMsg);

    if on == 1
        %% bit loading %%
        load('./data/bitAlloc.mat')
        load('./data/bitAllocSort.mat');
        load('./data/BitAllocSum.mat');
        load('./data/power_alloc.mat');
        rmsAlloc = [];
        ifftBlock = zeros(FFTSize, SToPcol);

        % Qammod 比特分配后,面向不同的子载波,有不同的M
        b = 1;

        for i = 1:length(bitAllocSort)

            if bitAllocSort(i) == 0
                QAMSymbols = 0;
                rmsAlloc = 0;
            else

                codeMsg1_per = OFDMSymbolNumber * bitAllocSort(i) * length(BitAllocSum{i}) * 2;
                codeMsg1_perloading = interleavedMsg(b:b + codeMsg1_per - 1, 1);
                b = codeMsg1_per + b;

                QAMSymbols = Qammod(bitAllocSort(i), codeMsg1_perloading);

                rms_alloc = rms(QAMSymbols);
                rmsAlloc = [rmsAlloc; rms_alloc];
                QAMSymbols = QAMSymbols / rms_alloc;
                QAMSymbols = reshape(QAMSymbols, length(BitAllocSum{i}), SToPcol);
            end

            carrierPosition = BitAllocSum{i};
            carrierPosition = carrierPosition + 2;
            ifftBlock(carrierPosition, :) = QAMSymbols;
        end

        % for i = 1:length(bitAlloc)

        %OFDMFrameReceiver是需要除相应的rms的，所以这个需要存起来
        file = ['./data/rmsAlloc' num2str(cir) '.mat'];
        save(file, 'rmsAlloc');

        % 功率加载
        for i = 1:SToPcol
            ifftBlock(DataCarrierPositions, i) = ifftBlock(DataCarrierPositions, i) .* sqrt(power_alloc');
        end

        %%
    else
        QAMSymbols = Qammod(BitsPerSymbolQAM, interleavedMsg);
        QAMSymbols = QAMSymbols / rms(QAMSymbols);

        % 在iteration函数里，最后一帧最后一次迭代算比特分配的时候，需要用QAMSymbols_trans去算SNR，根据SNR应用Chow，才能得到比特功率分配
        file = ['./data/QAMSymbols_trans' num2str(cir) '.mat'];
        save(file, 'QAMSymbols');
        QAMSymbols = reshape(QAMSymbols, length(DataCarrierPositions), SToPcol);
        ifftBlock = zeros(FFTSize, SToPcol);
        ifftBlock(DataCarrierPositions, :) = QAMSymbols;
    end

    OFDMSymbols = IFFT(ifftBlock);
