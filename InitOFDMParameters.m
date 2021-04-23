function OFDMParameters = InitOFDMParameters()

    %% ���Ʋ���,ͨ���ı����������Ʒ�������
    % on = 0 ѵ��(�������/���ʷ���)ģʽ��on = 1 ����(���ر���/���ʷ���)ģʽ
    global On; On = 0;
    % ��ǰ��֡,���������ȡ��/�Ƿ���б��ط���������
    global CurrentFrame; CurrentFrame = 1;

    %% OFDM����
    % ѭ��ǰ׺����
    global CPLength; CPLength = 20;
    % ѵ�����г���
    global PreambleNumber; PreambleNumber = 2;
    % FFT�ߴ�
    global FFTSize; FFTSize = 512;

    %% �������-ά�ر��������
    ConvConstLen = 7;
    ConvCodeGen = [171, 133];
    global trellis; trellis = poly2trellis (ConvConstLen, ConvCodeGen);
    % ά�ر�����������������
    global tblen; tblen = 120;
    % ������
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
    global PreambleCarriersNum; PreambleCarriersNum = length(PreambleCarrierPositions);
    global OFDMPositions; OFDMPositions = sort([1 DataCarrierPositions FFTSize / 2 + 1 FFTSize + 2 - DataCarrierPositions]);
    % ֡����
    global BitNumber; BitNumber = length(DataCarrierPositions) * OFDMSymbolNumber * BitsPerSymbolQAM;
    global PreambleBitNumber; PreambleBitNumber = length(PreambleCarrierPositions) * PreambleBitsPerSymbolQAM;
    %% Seed
    global PreambleSeed; PreambleSeed = 20;

    %% ��֯����
    % ��֯���
    global InterleaverDepth; InterleaverDepth = 32;

    %% QAM����
    % QAM8�ķ���
    global QAM8; QAM8 = [-1 - sqrt(3), -1 + 1i, -1 - 1i, 1i * (1 + sqrt(3)), -1i * (1 + sqrt(3)), 1 + 1i, 1 - 1i, 1 + sqrt(3)];
    % ��ͬ����������,QAM����rms������ֵ
    global RmsAlloc; RmsAlloc = [1, sqrt(2), sqrt(3 + sqrt(3)), sqrt(10), sqrt(20), sqrt(42), sqrt(82), sqrt(170)];

    %% ϵͳ�������
    global Iteration; Iteration = 5;

    %% ���Թ�ģ����
    global Seed; Seed = [10, 13, 21, 20, 8, 9, 15, 17, 19, 12, 11, 30, 25, 27, 26, 22, 14, 7, 23, 29];
    % global Seed; Seed = randi(30, [1, 20]);
    global FrameNum; FrameNum = 20;
    % global Seed; Seed = randi(100, [1, 100]);
    % global FrameNum; FrameNum = 100;
