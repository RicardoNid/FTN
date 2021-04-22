function none = Run()
    global CurrentFrame

    %% �����
    bitsAllFrame = []; % ���������ǰ
    OFDMBigFrame = []; % ����������
    CurrentFrame = 1;

    for cir = 1:20
        [Frame, BitsOneFrame] = OFDMFrameGenerator();
        bitsAllFrame = [bitsAllFrame; BitsOneFrame];
        OFDMBigFrame = [OFDMBigFrame, Frame];
        CurrentFrame = CurrentFrame + 1;
    end

    OFDMFrame = reshape(OFDMBigFrame, [], 1);

    %% �ŵ�
    OFDMFrame = filter([1, 0.8, 0.1, 0.05, 0.01, 0.005], 1, OFDMFrame);
    SNR = 12;
    snr = 10^(SNR / 10);
    code_power = norm(OFDMFrame)^2 / (length(OFDMFrame)); %�źŵķ��Ź��� =var(passchan_ofdm_symbol)
    sigma = sqrt(code_power / (snr * 2)); %sigma��μ��㣬�뵱ǰSNR���ź�ƽ�������й�ϵ
    [OFDMFrame_rec, ~] = addnoise(OFDMFrame, sigma); % use randn ����ֻ����ʵ��

    %% ���ջ�
    OFDMFrame_total = reshape(OFDMFrame_rec, [], 20);

    debitsAllFrame = [];

    for cir = 1:20
        OFDMFrame_rec_per = OFDMFrame_total(:, cir);
        [decodedMsg_HD] = OFDMFrameReceiver(OFDMFrame_rec_per, cir);
        debitsAllFrame = [debitsAllFrame; decodedMsg_HD];
    end

    [nErrors_HD, ber_HD] = biterr(bitsAllFrame, debitsAllFrame);
    display(nErrors_HD) % ����������������,���ڱ�֤�����޸ĵİ�ȫ��
    display(ber_HD)
