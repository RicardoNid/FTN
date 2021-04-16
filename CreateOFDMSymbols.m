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
    bitNumber = OFDMParameters.bitNumber;
    SToPcol = OFDMParameters.SToPcol;

    if on == 1
        %% bit loading %%
        load('./data/bitAllocSort.mat');
        load('./data/BitAllocSum.mat');
        load('./data/power_alloc.mat');
        rmsAlloc = [];
        ifftBlock = zeros(FFTSize, SToPcol);

        bits = randint(bitNumber, 1, 2, OFDMParameters.Seed(cir));
        bitsPerFrame = bits;
        %��OFDMFrameReceiver��vitdec����Ҫ�õ����bits
        file = ['./data/bits' num2str(cir) '.mat'];
        save(file, 'bits');

        % Channel Coding
        convCodedMsg = Convenc(bits);
        % Interleaving
        interleavedMsg = Interleave(convCodedMsg);

        % Qammod ���ط����,����ͬ�����ز�,�в�ͬ��M
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

        %OFDMFrameReceiver����Ҫ����Ӧ��rms�ģ����������Ҫ������
        file = ['./data/rmsAlloc' num2str(cir) '.mat'];
        save(file, 'rmsAlloc');

        % ���ʼ���
        for i = 1:SToPcol
            ifftBlock(DataCarrierPositions, i) = ifftBlock(DataCarrierPositions, i) .* sqrt(power_alloc');
        end

        %%
    else
        % Random bitgen
        bits = randint(bitNumber, 1, 2, OFDMParameters.Seed(cir)); %ÿ��cir��Ӧ����������һ������Ϊ��֡����Ҫ��һ��
        bitsPerFrame = bits;
        % Code properties(channel coding)
        convCodedMsg = Convenc(bits);
        % Interleaving
        interleavedMsg = Interleave(convCodedMsg);

        % mapping���Դ���qammod)
        M = 2^BitsPerSymbolQAM;
        modObj = modem.qammod('M', M, 'SymbolOrder', 'Gray', 'InputType', 'Bit');
        QAMSymbols = modulate(modObj, interleavedMsg);
        QAMSymbols = QAMSymbols / rms(QAMSymbols);

        % ��iteration��������һ֡���һ�ε�������ط����ʱ����Ҫ��QAMSymbols_transȥ��SNR������SNRӦ��Chow�����ܵõ����ع��ʷ���
        file = ['./data/QAMSymbols_trans' num2str(cir) '.mat'];
        save(file, 'QAMSymbols');
        QAMSymbols = reshape(QAMSymbols, length(DataCarrierPositions), SToPcol);
        ifftBlock = zeros(FFTSize, SToPcol);
        ifftBlock(DataCarrierPositions, :) = QAMSymbols;
    end

    OFDMSymbols = IFFT(ifftBlock);
