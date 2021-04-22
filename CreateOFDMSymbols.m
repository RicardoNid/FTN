%  // ======================================================================
%  //  Jinan University
%  //  @Author: JiZhou CanyangXiong
%  //  @Last Modified time: 2021-03-05
%  //  @description: 生成FTN符号
%  // ======================================================================
function [OFDMSymbols, bitsPerFrame] = CreateOFDMSymbols(OFDMParameters, cir)
    on = OFDMParameters.on;
    global FFTSize;
    global OFDMSymbolNumber;
    global BitsPerSymbolQAM;
    global DataCarrierPositions;
    global SToPcol;
    global RmsAlloc;

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
        ifftBlock = zeros(FFTSize, SToPcol);

        b = 1;

        for i = 1:length(bitAllocSort)

            if bitAllocSort(i) == 0
                QAMSymbols = 0;
            else
                codeMsg1_per = OFDMSymbolNumber * bitAllocSort(i) * length(BitAllocSum{i}) * 2;
                codeMsg1_perloading = interleavedMsg(b:b + codeMsg1_per - 1, 1);
                b = codeMsg1_per + b;
                QAMSymbols = Qammod(bitAllocSort(i), codeMsg1_perloading);
                QAMSymbols = QAMSymbols / RmsAlloc(bitAllocSort(i));
                QAMSymbols = reshape(QAMSymbols, length(BitAllocSum{i}), SToPcol);
            end

            carrierPosition = BitAllocSum{i};
            carrierPosition = carrierPosition + 2;
            ifftBlock(carrierPosition, :) = QAMSymbols;
        end

        % 功率加载
        for i = 1:SToPcol
            ifftBlock(DataCarrierPositions, i) = ifftBlock(DataCarrierPositions, i) .* sqrt(power_alloc');
        end

    else
        QAMSymbols = Qammod(BitsPerSymbolQAM, interleavedMsg);
        QAMSymbols = QAMSymbols / RmsAlloc(4);

        % 实际训练(on = 0)时,整个训练帧都是已知的,因此文件传递是合法的
        file = ['./data/QAMSymbols_trans' num2str(cir) '.mat'];
        save(file, 'QAMSymbols');
        QAMSymbols = reshape(QAMSymbols, length(DataCarrierPositions), SToPcol);
        ifftBlock = zeros(FFTSize, SToPcol);
        ifftBlock(DataCarrierPositions, :) = QAMSymbols;
    end

    % DataForCarriers = DynamicQammod(interleavedMsg, on, cir);
    % ifftBlock = zeros(FFTSize, SToPcol);
    % ifftBlock(DataCarrierPositions, :) = DataForCarriers;

    OFDMSymbols = IFFT(ifftBlock);
