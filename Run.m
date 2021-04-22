function none = Run()
    global CurrentFrame

    %% 发射机
    bitsAllFrame = []; % 发射机处理前
    OFDMBigFrame = []; % 发射机处理后
    CurrentFrame = 1;

    for cir = 1:20
        [Frame, BitsOneFrame] = OFDMFrameGenerator();
        bitsAllFrame = [bitsAllFrame; BitsOneFrame];
        OFDMBigFrame = [OFDMBigFrame, Frame];
        CurrentFrame = CurrentFrame + 1;
    end

    OFDMFrame = reshape(OFDMBigFrame, [], 1);

    %% 信道
    OFDMFrame = filter([1, 0.8, 0.1, 0.05, 0.01, 0.005], 1, OFDMFrame);
    SNR = 12;
    snr = 10^(SNR / 10);
    code_power = norm(OFDMFrame)^2 / (length(OFDMFrame)); %信号的符号功率 =var(passchan_ofdm_symbol)
    sigma = sqrt(code_power / (snr * 2)); %sigma如何计算，与当前SNR和信号平均能量有关系
    [OFDMFrame_rec, ~] = addnoise(OFDMFrame, sigma); % use randn 噪声只加了实部

    %% 接收机
    OFDMFrame_total = reshape(OFDMFrame_rec, [], 20);

    debitsAllFrame = [];

    for cir = 1:20
        OFDMFrame_rec_per = OFDMFrame_total(:, cir);
        [decodedMsg_HD] = OFDMFrameReceiver(OFDMFrame_rec_per, cir);
        debitsAllFrame = [debitsAllFrame; decodedMsg_HD];
    end

    [nErrors_HD, ber_HD] = biterr(bitsAllFrame, debitsAllFrame);
    display(nErrors_HD) % 误码数量和误码率,用于保证代码修改的安全性
    display(ber_HD)
