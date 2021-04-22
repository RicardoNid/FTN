function preamble = CreateOFDMPreamble()
    global RmsAlloc
    global PreambleCarrierPositions
    global PreambleBitsPerSymbolQAM
    global FFTSize
    global CPLength
    global PreambleNumber
    global PreambleSeed
    global PreambleBitNumber

    %% 此部分无需硬件实现
    preambleBits = randint(PreambleBitNumber, 1, 2, PreambleSeed);
    preambleQAMSymbols = GrayQAMCoder(preambleBits, PreambleBitsPerSymbolQAM);
    preambleQAMSymbols = preambleQAMSymbols / RmsAlloc(4);
    save './data/preambleQAMSymbols' preambleQAMSymbols % 训练QAM符号,存储在接收机与发射机

    %% 此部分无需硬件实现,预计算后存储在发射机
    ifftBlock = zeros(FFTSize, 1); % padding为ifftBlock
    ifftBlock(PreambleCarrierPositions) = preambleQAMSymbols;
    ifftBlock(FFTSize + 2 - PreambleCarrierPositions) = conj(preambleQAMSymbols);
    preamble = ifft(ifftBlock); % 进行ifft
    preamble = [preamble(end - CPLength / 2 + 1:end); preamble; preamble(1:CPLength / 2)]; % 增加循环前缀

    save './data/preamble' preamble % 训练OFDM符号,存储在发射机

    preamble = repmat(preamble, PreambleNumber, 1); %重复2次
