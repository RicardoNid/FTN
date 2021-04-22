%  // ======================================================================
%  //  Jinan University
%  //  @Author: JiZhou CanyangXiong
%  //  @Last Modified time: 2021-03-05
%  //  @description: 1个子帧（有用信息+训练序列）
%  // ======================================================================
function [OFDMSmallFrame, bits] = OFDMFrameGenerator(OFDMParameters, cir)
    [OFDMSymbols, bits] = CreateOFDMSymbols(OFDMParameters, cir);
    preamble = CreateOFDMPreamble(OFDMParameters);
    OFDMSmallFrame = [preamble; OFDMSymbols]; % 训练数据和message构成一个子帧
