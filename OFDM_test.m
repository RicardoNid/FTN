close all
warning off all
clc

InitOFDMParameters(); % 初始化全局变量
global On
global CurrentFrame

Run(); % 以比特分配(训练)模式运行一次系统

On = 1;
CurrentFrame = 1;

Run(); % 以比特加载(工作)模式运行一次系统

%% 运行完毕之后,清楚数据文件,以防残留的数据文件掩盖代码修改后的问题
delete './data/bitAlloc.mat'
delete './data/bitAllocSort.mat'
delete './data/bitAllocSum.mat'
delete './data/preamble.mat'
delete './data/preambleQAMSymbols.mat'
delete './data/QAMSymbols_trans.mat'
delete './data/power_alloc.mat'
