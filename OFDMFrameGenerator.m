%  // ======================================================================
%  //  Jinan University
%  //  @Author: JiZhou CanyangXiong
%  //  @Last Modified time: 2021-03-05      
%  //  @description: 1个子帧（有用信息+训练序列）
%  // ======================================================================
function [OFDMSmallFrame, bits] = OFDMFrameGenerator(OFDMParameters,cir)
[OFDMSymbols,bits] = CreateOFDMSymbols(OFDMParameters,cir); %有用信息，每个子帧的有用信息不一样，seed不一样
preamble = CreateOFDMPreamble(OFDMParameters);%训练序列，每个子帧的训练序列的seed是一样的
OFDMSmallFrame = [preamble; OFDMSymbols]; %构成一个子帧


