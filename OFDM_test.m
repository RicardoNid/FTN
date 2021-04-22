close all
warning off all
clc

InitOFDMParameters(); % 初始化全局变量
global On
global CurrentFrame

Run(); % 运行一遍比特分配(训练)模式

On = 1;
CurrentFrame = 1;

Run(); % 运行一遍比特加载(工作)模式
