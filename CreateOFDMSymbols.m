function [OFDMSymbols, bitsPerFrame] = CreateOFDMSymbols()

    global On
    global CurrentFrame
    global SToPcol

    bits = BitGen();
    bitsPerFrame = bits; % ÅÔÂ·

    QAMSymbols = Bits2QAM(bits);

    if On == 1
        load('./data/power_alloc.mat');

        for i = 1:SToPcol
            QAMSymbols(:, i) = QAMSymbols(:, i) .* sqrt(power_alloc');
        end

    end

    OFDMSymbols = IFFT(QAMSymbols);
