function OFDMSmallFrame = OFDMFrameGenerator(bits)
    OFDMSymbols = CreateOFDMSymbols(bits); % �ӹ���Ϣ����
    preamble = CreateOFDMPreamble(); % ���ѵ������
    OFDMSmallFrame = [preamble; OFDMSymbols]; % ѵ�����ݺ���Ϣ����һ����֡
