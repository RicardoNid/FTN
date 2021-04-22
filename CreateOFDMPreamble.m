function preamble = CreateOFDMPreamble()
    global RmsAlloc
    global PreambleCarrierPositions
    global PreambleBitsPerSymbolQAM
    global FFTSize
    global CPLength
    global PreambleNumber
    global PreambleSeed
    global PreambleBitNumber

    %% �˲�������Ӳ��ʵ��
    preambleBits = randint(PreambleBitNumber, 1, 2, PreambleSeed);
    preambleQAMSymbols = GrayQAMCoder(preambleBits, PreambleBitsPerSymbolQAM);
    preambleQAMSymbols = preambleQAMSymbols / RmsAlloc(4);
    save './data/preambleQAMSymbols' preambleQAMSymbols % ѵ��QAM����,�洢�ڽ��ջ��뷢���

    %% �˲�������Ӳ��ʵ��,Ԥ�����洢�ڷ����
    ifftBlock = zeros(FFTSize, 1); % paddingΪifftBlock
    ifftBlock(PreambleCarrierPositions) = preambleQAMSymbols;
    ifftBlock(FFTSize + 2 - PreambleCarrierPositions) = conj(preambleQAMSymbols);
    preamble = ifft(ifftBlock); % ����ifft
    preamble = [preamble(end - CPLength / 2 + 1:end); preamble; preamble(1:CPLength / 2)]; % ����ѭ��ǰ׺

    save './data/preamble' preamble % ѵ��OFDM����,�洢�ڷ����

    preamble = repmat(preamble, PreambleNumber, 1); %�ظ�2��
