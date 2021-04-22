%  // ======================================================================
%  //  Jinan University
%  //  @Author: JiZhou CanyangXiong
%  //  @Last Modified time: 2021-03-05
%  //  @description: 1����֡��������Ϣ+ѵ�����У�
%  // ======================================================================
function [OFDMSmallFrame, bits] = OFDMFrameGenerator(OFDMParameters, cir)
    [OFDMSymbols, bits] = CreateOFDMSymbols(OFDMParameters, cir);
    preamble = CreateOFDMPreamble(OFDMParameters);
    OFDMSmallFrame = [preamble; OFDMSymbols]; % ѵ�����ݺ�message����һ����֡
