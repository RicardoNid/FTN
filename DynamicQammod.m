function QAMSymbols = DynamicQammod(bits)
    global On
    global SToPcol
    global BitsPerSymbolQAM
    global OFDMSymbolNumber
    global RmsAlloc
    global SubcarriersNum
    global ConvCodeRate

    if On == 1 % 工作时,根据训练结果,每个子载波分配相应比特数(0-8 bits)
        %% bit loading %%
        load('./data/bitAlloc.mat') % 比特分配,训练模式后接收机反馈的信息之一, 后两个文件描述第一个文件的内容
        load('./data/bitAllocSort.mat');
        load('./data/BitAllocSum.mat');

        QAMSymbols = zeros(SubcarriersNum, SToPcol);

        segmentHead = 1;

        for i = 1:length(bitAllocSort)

            bitAllocated = bitAllocSort(i); % 当前要处理的子载波(群)被分配的比特数

            if bitAllocated == 0
                QAMSymbol = 0;
            else
                bitsLength = OFDMSymbolNumber * bitAllocated * length(BitAllocSum{i}) / ConvCodeRate; % 计算总长度
                bitsTobeMapped = bits(segmentHead:segmentHead + bitsLength - 1, 1); % 依照长度获取待映射比特
                segmentHead = bitsLength + segmentHead; % 维护待取比特位置

                QAMSymbol = Qammod(bitAllocated, bitsTobeMapped); % 依照分配比特数映射
                QAMSymbol = QAMSymbol / RmsAlloc(bitAllocated); % ?? 静态归一化
                QAMSymbol = reshape(QAMSymbol, length(BitAllocSum{i}), SToPcol); % 串->并转换
            end

            carrierPosition = BitAllocSum{i}; % 该分配比特数所对应的子载波位置
            QAMSymbols(carrierPosition, :) = QAMSymbol; % 将映射后的符号串->并装换填入对应子载波位置
        end

    else % 训练时,每个子载波分配固定比特(4)
        QAMSymbols = Qammod(BitsPerSymbolQAM, bits);
        QAMSymbols = QAMSymbols / RmsAlloc(4); % ?? 静态归一化
        QAMSymbols = reshape(QAMSymbols, SubcarriersNum, SToPcol); % 串->并转换
    end
