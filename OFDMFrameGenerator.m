%  // ======================================================================
%  //  Jinan University
%  //  @Author: JiZhou CanyangXiong
%  //  @Last Modified time: 2021-03-05      
%  //  @description: 1����֡��������Ϣ+ѵ�����У�
%  // ======================================================================
function [OFDMSmallFrame, bits] = OFDMFrameGenerator(OFDMParameters,cir)
[OFDMSymbols,bits] = CreateOFDMSymbols(OFDMParameters,cir); %������Ϣ��ÿ����֡��������Ϣ��һ����seed��һ��
preamble = CreateOFDMPreamble(OFDMParameters);%ѵ�����У�ÿ����֡��ѵ�����е�seed��һ����
OFDMSmallFrame = [preamble; OFDMSymbols]; %����һ����֡


