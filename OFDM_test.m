close all
warning off all
clc

InitOFDMParameters(); % ��ʼ��ȫ�ֱ���
global On
global CurrentFrame

Run(); % �Ա��ط���(ѵ��)ģʽ����һ��ϵͳ

On = 1;
CurrentFrame = 1;

Run(); % �Ա��ؼ���(����)ģʽ����һ��ϵͳ

%% �������֮��,��������ļ�,�Է������������ļ��ڸǴ����޸ĺ������
delete './data/bitAlloc.mat'
delete './data/bitAllocSort.mat'
delete './data/bitAllocSum.mat'
delete './data/preamble.mat'
delete './data/preambleQAMSymbols.mat'
delete './data/QAMSymbols_trans.mat'
delete './data/power_alloc.mat'
