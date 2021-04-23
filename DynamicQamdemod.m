function Demodulated = DynamicQamdemod(FDE)
    global On
    global BitsPerSymbolQAM;
    global RmsAlloc

    if On == 1 % ����ʱ,����ѵ�����,ÿ�����ز�������Ӧ������(0-8 bits)
        load('./data/bitAllocSort.mat');
        load('./data/BitAllocSum.mat');

        % ?? ����Ĵ����޷�������ط�����0�����
        Demodulated = [];

        for i = 1:length(bitAllocSort)

            bitAllocated = bitAllocSort(i); % ��ǰҪ��������ز�(Ⱥ)������ı�����

            if bitAllocated ~= 0
                carrierPosition = BitAllocSum{i}; % ����ı���������Ӧ�����ڲ�
                QAM = reshape(FDE(carrierPosition, :), [], 1); % ��ȡ����ӳ�����,��->��ת��
                demodulated = Qamdemod(bitAllocated, QAM); % ���շ����������ӳ��
                Demodulated = [Demodulated, demodulated]; % ����ƴ�ӷ�ʽ��ӳ��ʱһ��,�������ݱ�������ͬ������
            end

        end

    else % ѵ��ʱ,ÿ�����ز�����̶�����(4)
        FDE = reshape(FDE, [], 1); % ��->��ת��
        FDE = FDE / rms(FDE) * RmsAlloc(4); % ?? �˴�����Ҳ�ǲ���Ҫ��
        Demodulated = Qamdemod(BitsPerSymbolQAM, FDE);
    end
