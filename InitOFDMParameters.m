function OFDMParameters = InitOFDMParameters()
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
    OFDMParameters.PreambleCarrierPositions = [-OFDMParameters.FFTSize / 2 + 1:-1] + OFDMParameters.FFTSize / 2 + 1;
    OFDMParameters.PreambleBitsPerSymbolQAM = 4;
    OFDMParameters.PreambleSeed = 20;

    % OFDMSymbolNumber*2  S/P的列数 编码效率1/2,k=1,n=2
    OFDMParameters.codeRate = 1/2;
    OFDMParameters.bitNumber = OFDMParameters.OFDMSymbolNumber * length(OFDMParameters.DataCarrierPositions) * OFDMParameters.BitsPerSymbolQAM;
    OFDMParameters.SToPcol = ((OFDMParameters.bitNumber * (1 / OFDMParameters.codeRate)) / OFDMParameters.BitsPerSymbolQAM) / length(OFDMParameters.DataCarrierPositions);

    global BitsPerSymbolQAM
    BitsPerSymbolQAM = 4;

    global DataCarrierPositions
    DataCarrierPositions = 3:226;

    global OFDMSymbolNumber
    OFDMSymbolNumber = 8;

    global PreambleSeed
    PreambleSeed = 20;

    global Seed
    Seed = [10, 13, 21, 20, 8, 9, 15, 17, 19, 12, 11, 30, 25, 27, 26, 22, 14, 7, 23, 29];

    global bitNumber
    bitNumber = length(DataCarrierPositions) * OFDMSymbolNumber * BitsPerSymbolQAM;

    global FFTSize
    FFTSize = 512;

    global SubcarriersNum
    SubcarriersNum = length(OFDMParameters.DataCarrierPositions);

    %% 卷积编码-维特比译码参数
    global ConvConstLen
    ConvConstLen = 7;

    global ConvCodeGen
    ConvCodeGen = [171, 133];

    global tblen
    tblen = 90;
