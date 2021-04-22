function QAMSymbols = DynamicQammod(bits)
    global On
    global SToPcol
    global BitsPerSymbolQAM
    global OFDMSymbolNumber
    global RmsAlloc
    global SubcarriersNum
    global ConvCodeRate

    if On == 1 % ����ʱ,����ѵ�����,ÿ�����ز�������Ӧ������(0-8 bits)
        %% bit loading %%
        load('./data/bitAlloc.mat') % ���ط���,ѵ��ģʽ����ջ���������Ϣ֮һ, �������ļ�������һ���ļ�������
        load('./data/bitAllocSort.mat');
        load('./data/BitAllocSum.mat');

        QAMSymbols = zeros(SubcarriersNum, SToPcol);

        segmentHead = 1;

        for i = 1:length(bitAllocSort)

            bitAllocated = bitAllocSort(i); % ��ǰҪ��������ز�(Ⱥ)������ı�����

            if bitAllocated == 0
                QAMSymbol = 0;
            else
                bitsLength = OFDMSymbolNumber * bitAllocated * length(BitAllocSum{i}) / ConvCodeRate; % �����ܳ���
                bitsTobeMapped = bits(segmentHead:segmentHead + bitsLength - 1, 1); % ���ճ��Ȼ�ȡ��ӳ�����
                segmentHead = bitsLength + segmentHead; % ά����ȡ����λ��

                QAMSymbol = Qammod(bitAllocated, bitsTobeMapped); % ���շ��������ӳ��
                QAMSymbol = QAMSymbol / RmsAlloc(bitAllocated); % ?? ��̬��һ��
                QAMSymbol = reshape(QAMSymbol, length(BitAllocSum{i}), SToPcol); % ��->��ת��
            end

            carrierPosition = BitAllocSum{i}; % �÷������������Ӧ�����ز�λ��
            QAMSymbols(carrierPosition, :) = QAMSymbol; % ��ӳ���ķ��Ŵ�->��װ�������Ӧ���ز�λ��
        end

    else % ѵ��ʱ,ÿ�����ز�����̶�����(4)
        QAMSymbols = Qammod(BitsPerSymbolQAM, bits);
        QAMSymbols = QAMSymbols / RmsAlloc(4); % ?? ��̬��һ��
        QAMSymbols = reshape(QAMSymbols, SubcarriersNum, SToPcol); % ��->��ת��
    end
