function OFDMParameters = InitOFDMParameters()
    % on=0����ط��䣬on=1���ؼ���
    OFDMParameters.on = 0;
    OFDMParameters.CPLength = 20;
    OFDMParameters.PreambleNumber = 2;
    OFDMParameters.FFTSize = 512;
    OFDMParameters.OFDMSymbolNumber = 8; %OFDM��������
    OFDMParameters.iteration = 5;

    %ʵ��
    OFDMParameters.DataCarrierPositions = [3:226];
    OFDMParameters.OFDMPositions = sort([1 OFDMParameters.DataCarrierPositions OFDMParameters.FFTSize / 2 + 1 OFDMParameters.FFTSize + 2 - OFDMParameters.DataCarrierPositions]);
    OFDMParameters.BitsPerSymbolQAM = 4;

    % һ��20����֡��ÿ����֡�����ݲ�һ����seed����һ��
    OFDMParameters.Seed = [10, 13, 21, 20, 8, 9, 15, 17, 19, 12, 11, 30, 25, 27, 26, 22, 14, 7, 23, 29];
    OFDMParameters.PreambleCarrierPositions = [-OFDMParameters.FFTSize / 2 + 1:-1] + OFDMParameters.FFTSize / 2 + 1;
    OFDMParameters.PreambleBitsPerSymbolQAM = 4;
    OFDMParameters.PreambleSeed = 20;

    % OFDMSymbolNumber*2  S/P������ ����Ч��1/2,k=1,n=2
    OFDMParameters.codeRate = 1/2;
    OFDMParameters.bitNumber = OFDMParameters.OFDMSymbolNumber * length(OFDMParameters.DataCarrierPositions) * OFDMParameters.BitsPerSymbolQAM;
    OFDMParameters.SToPcol = ((OFDMParameters.bitNumber * (1 / OFDMParameters.codeRate)) / OFDMParameters.BitsPerSymbolQAM) / length(OFDMParameters.DataCarrierPositions);

    global FFTSize
    FFTSize = 512;

    global DataCarrierPositions
    DataCarrierPositions = 3:226;

    global SubcarriersNum
    SubcarriersNum = length(OFDMParameters.DataCarrierPositions);
