close all
warning off all
clc

InitOFDMParameters(); % ��ʼ��ȫ�ֱ���
global On
global CurrentFrame

Run(); % ����һ����ط���(ѵ��)ģʽ

On = 1;
CurrentFrame = 1;

Run(); % ����һ����ؼ���(����)ģʽ
