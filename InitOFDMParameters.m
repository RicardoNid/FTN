function OFDMParameters = InitOFDMParameters()

    %% on = 0 ѵ��(������ط���)��on = 1 ����
    global On; On = 0;
    global CurrentFrame; CurrentFrame = 1;

    global BitAllocCal; BitAllocCal = 0;

    %% OFDM����
    global CPLength; CPLength = 20;
    global PreambleNumber; PreambleNumber = 2;
    global FFTSize; FFTSize = 512;

    %% �������-ά�ر��������
    global ConvConstLen; ConvConstLen = 7;
    global ConvCodeGen; ConvCodeGen = [171, 133];
    global tblen; tblen = 90;
    global ConvCodeRate; ConvCodeRate = 1/2;

    % Symbol
    global OFDMSymbolNumber; OFDMSymbolNumber = 8;
    global BitsPerSymbolQAM; BitsPerSymbolQAM = 4;
    global PreambleBitsPerSymbolQAM; PreambleBitsPerSymbolQAM = 4;
    global SToPcol; SToPcol = OFDMSymbolNumber / ConvCodeRate;
    % ���ز�
    global DataCarrierPositions; DataCarrierPositions = 3:226;
    global PreambleCarrierPositions; PreambleCarrierPositions = 2:FFTSize / 2;
    global SubcarriersNum; SubcarriersNum = length(DataCarrierPositions);
    global OFDMPositions; OFDMPositions = sort([1 DataCarrierPositions FFTSize / 2 + 1 FFTSize + 2 - DataCarrierPositions]);
    % ֡����
    global BitNumber; BitNumber = length(DataCarrierPositions) * OFDMSymbolNumber * BitsPerSymbolQAM;
    global PreambleBitNumber; PreambleBitNumber = length(PreambleCarrierPositions) * PreambleBitsPerSymbolQAM;
    %% Seed
    global Seed; Seed = [10, 13, 21, 20, 8, 9, 15, 17, 19, 12, 11, 30, 25, 27, 26, 22, 14, 7, 23, 29];
    global PreambleSeed; PreambleSeed = 20;

    %% ��֯����
    global InterleaverDepth; InterleaverDepth = 32;

    global RmsAlloc; RmsAlloc = [1, sqrt(2), sqrt(3 + sqrt(3)), sqrt(10), sqrt(20), sqrt(42), sqrt(82), sqrt(170)];

    global Iteration; Iteration = 5;
