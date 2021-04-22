function OFDMSymbols = CreateOFDMSymbols(bits)
    global On
    global SToPcol

    QAMSymbols = Bits2QAM(bits); % ������� -> ��֯ -> QAMӳ��

    % ����QAMSymbols���ڱ��ط���
    % ʵ��ʵ����,���ط�����ù̶�����֡,��Ӧ��QAM����,�洢�ڽ��ջ��뷢���
    file = './data/QAMSymbols_trans.mat';
    save(file, 'QAMSymbols');

    if On == 1
        load('./data/power_alloc.mat'); % ���ʷ���,ѵ��ģʽ����ջ���������Ϣ֮һ

        for i = 1:SToPcol
            QAMSymbols(:, i) = QAMSymbols(:, i) .* sqrt(power_alloc'); % ���ز����ʷ���
        end

    end

    OFDMSymbols = IFFT(QAMSymbols); % ifft
