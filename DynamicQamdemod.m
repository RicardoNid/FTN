function Demodulated = DynamicQamdemod(FDE)
    global On
    global BitsPerSymbolQAM;
    global RmsAlloc

    if On == 1 % 工作时,根据训练结果,每个子载波分配相应比特数(0-8 bits)
        load('./data/bitAllocSort.mat');
        load('./data/BitAllocSum.mat');

        % ?? 这里的代码无法处理比特分配有0的情况
        Demodulated = [];

        for i = 1:length(bitAllocSort)

            bitAllocated = bitAllocSort(i); % 当前要处理的子载波(群)被分配的比特数

            if bitAllocated ~= 0
                carrierPosition = BitAllocSum{i}; % 分配的比特数所对应的子在播
                QAM = reshape(FDE(carrierPosition, :), [], 1); % 获取待解映射符号,并->串转换
                demodulated = Qamdemod(bitAllocated, QAM); % 依照分配比特数解映射
                Demodulated = [Demodulated, demodulated]; % 数据拼接方式和映射时一致,近邻数据被分配相同比特数
            end

        end

    else % 训练时,每个子载波分配固定比特(4)
        FDE = reshape(FDE, [], 1); % 并->串转换
        FDE = FDE / rms(FDE) * RmsAlloc(4); % ?? 此处可能也是不必要的
        Demodulated = Qamdemod(BitsPerSymbolQAM, FDE); % 1*14336
    end
