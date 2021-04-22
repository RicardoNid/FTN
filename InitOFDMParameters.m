function OFDMParameters = InitOFDMParameters()

    %% on = 0 训练(计算比特分配)，on = 1 工作
    global On; On = 0;
    global BitAllocCal; BitAllocCal = 0;

    %% OFDM参数
    global CPLength; CPLength = 20;
    global PreambleNumber; PreambleNumber = 2;
    global FFTSize; FFTSize = 512;

    %% 卷积编码-维特比译码参数
    global ConvConstLen; ConvConstLen = 7;
    global ConvCodeGen; ConvCodeGen = [171, 133];
    global tblen; tblen = 90;
    global ConvCodeRate; ConvCodeRate = 1/2;

    % Symbol
    global OFDMSymbolNumber; OFDMSymbolNumber = 8;
    global BitsPerSymbolQAM; BitsPerSymbolQAM = 4;
    global PreambleBitsPerSymbolQAM; PreambleBitsPerSymbolQAM = 4;
    global SToPcol; SToPcol = OFDMSymbolNumber / ConvCodeRate;
    % 子载波
    global DataCarrierPositions; DataCarrierPositions = 3:226;
    global PreambleCarrierPositions; PreambleCarrierPositions = 2:FFTSize / 2;
    global SubcarriersNum; SubcarriersNum = length(DataCarrierPositions);
    global OFDMPositions; OFDMPositions = sort([1 DataCarrierPositions FFTSize / 2 + 1 FFTSize + 2 - DataCarrierPositions]);
    % 帧长度
    global bitNumber; bitNumber = length(DataCarrierPositions) * OFDMSymbolNumber * BitsPerSymbolQAM;

    %% Seed
    global Seed; Seed = [10, 13, 21, 20, 8, 9, 15, 17, 19, 12, 11, 30, 25, 27, 26, 22, 14, 7, 23, 29];
    global PreambleSeed; PreambleSeed = 20;

    %% 交织参数
    global InterleaverDepth; InterleaverDepth = 32;

    global RmsAlloc; RmsAlloc = [1, sqrt(2), sqrt(3 + sqrt(3)), sqrt(10), sqrt(20), sqrt(42), sqrt(82), sqrt(170)];

    global Iteration; Iteration = 5;

    % on=0算比特分配，on=1比特加载
    OFDMParameters.on = 0;
    OFDMParameters.CPLength = 20;
    OFDMParameters.PreambleNumber = 2;
    OFDMParameters.FFTSize = 512;
    OFDMParameters.OFDMSymbolNumber = 8; %OFDM符号数量
    OFDMParameters.iteration = 5;

    %实数
    OFDMParameters.DataCarrierPositions = [3:226];
    OFDMParameters.OFDMPositions = sort([1 OFDMParameters.DataCarrierPositions OFDMParameters.FFTSize / 2 + 1 OFDMParameters.FFTSize + 2 - OFDMParameters.DataCarrierPositions]);
    OFDMParameters.BitsPerSymbolQAM = 4;

    % 一共20个子帧，每个子帧的数据不一样，seed数不一样
    OFDMParameters.Seed = [10, 13, 21, 20, 8, 9, 15, 17, 19, 12, 11, 30, 25, 27, 26, 22, 14, 7, 23, 29];
    OFDMParameters.PreambleCarrierPositions = 2:FFTSize / 2;
    OFDMParameters.PreambleBitsPerSymbolQAM = 4;
    OFDMParameters.PreambleSeed = 20;

    % OFDMSymbolNumber*2  S/P的列数 编码效率1/2,k=1,n=2
    OFDMParameters.codeRate = 1/2;
    OFDMParameters.bitNumber = OFDMParameters.OFDMSymbolNumber * length(OFDMParameters.DataCarrierPositions) * OFDMParameters.BitsPerSymbolQAM;
    OFDMParameters.SToPcol = OFDMParameters.OFDMSymbolNumber / OFDMParameters.codeRate;
