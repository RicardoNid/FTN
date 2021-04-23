function OFDMSymbols = CreateOFDMSymbols(bits)
    global On
    global PowerOn

    QAMSymbols = Bits2QAM(bits); % 卷积编码 -> 交织 -> QAM映射

    % 保存QAMSymbols用于比特分配
    % 实际实现中,比特分配采用固定的子帧,对应的QAM符号,同时存储在接收机与发射机
    file = './data/QAMSymbols_trans.mat';
    save(file, 'QAMSymbols');

    if On == 1 % 工作时,根据训练结果,每个子载波分配相应比功率
        PowerOn = 1;
        QAMSymbols = PowerOnOff(QAMSymbols);
    end

    OFDMSymbols = IFFT(QAMSymbols); % ifft
