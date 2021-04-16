%  // ======================================================================
%  //  Jinan University
%  //  @Author: JiZhou CanyangXiong
%  //  @Last Modified time: 2021-03-05
%  //  @description: ����FTN����
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

        % Qammod ���ط����,����ͬ�����ز�,�в�ͬ��M
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

        %OFDMFrameReceiver����Ҫ����Ӧ��rms�ģ����������Ҫ������
        file = ['./data/rmsAlloc' num2str(cir) '.mat'];
        save(file, 'rmsAlloc');

        % ���ʼ���
        for i = 1:SToPcol
            ifftBlock(DataCarrierPositions, i) = ifftBlock(DataCarrierPositions, i) .* sqrt(power_alloc');
        end

        %%
    else
        QAMSymbols = Qammod(BitsPerSymbolQAM, interleavedMsg);
        QAMSymbols = QAMSymbols / rms(QAMSymbols);

        % ��iteration��������һ֡���һ�ε�������ط����ʱ����Ҫ��QAMSymbols_transȥ��SNR������SNRӦ��Chow�����ܵõ����ع��ʷ���
        file = ['./data/QAMSymbols_trans' num2str(cir) '.mat'];
        save(file, 'QAMSymbols');
        QAMSymbols = reshape(QAMSymbols, length(DataCarrierPositions), SToPcol);
        ifftBlock = zeros(FFTSize, SToPcol);
        ifftBlock(DataCarrierPositions, :) = QAMSymbols;
    end

    OFDMSymbols = IFFT(ifftBlock);
