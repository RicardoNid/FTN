function OFDMSmallFrame = OFDMFrameGenerator(bits)
    OFDMSymbols = CreateOFDMSymbols(bits); % 加工信息比特
    preamble = CreateOFDMPreamble(); % 获得训练序列
    OFDMSmallFrame = [preamble; OFDMSymbols]; % 训练数据和信息构成一个子帧
