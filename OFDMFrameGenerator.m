%  // ======================================================================
%  //  Jinan University
%  //  @Author: JiZhou CanyangXiong
%  //  @Last Modified time: 2021-03-05
%  //  @description: 1����֡��������Ϣ+ѵ�����У�
%  // ======================================================================
function [OFDMSmallFrame, bits] = OFDMFrameGenerator()
    [OFDMSymbols, bits] = CreateOFDMSymbols();
    preamble = CreateOFDMPreamble();
    OFDMSmallFrame = [preamble; OFDMSymbols]; % ѵ�����ݺ�message����һ����֡
