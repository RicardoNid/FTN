function OFDMSymbols = CreateOFDMSymbols(bits)
    global On
    global SToPcol

    QAMSymbols = Bits2QAM(bits); % 卷积编码 -> 交织 -> QAM映射

    % 保存QAMSymbols用于比特分配
    % 实际实现中,比特分配采用固定的子帧,对应的QAM符号,存储在接收机与发射机
    file = './data/QAMSymbols_trans.mat';
    save(file, 'QAMSymbols');

    if On == 1
        load('./data/power_alloc.mat'); % 功率分配,训练模式后接收机反馈的信息之一

        for i = 1:SToPcol
            QAMSymbols(:, i) = QAMSymbols(:, i) .* sqrt(power_alloc'); % 子载波功率分配
        end

    end

    OFDMSymbols = IFFT(QAMSymbols); % ifft
