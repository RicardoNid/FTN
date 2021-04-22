function [OFDMSymbols] = IFFT(QAMSymbols)
    global DataCarrierPositions
    global FFTSize
    global OFDMPositions
    global CPLength
    global SToPcol

    ifftBlock = zeros(FFTSize, SToPcol); % 构造FFT数据
    ifftBlock(DataCarrierPositions, :) = QAMSymbols;
    ifftBlock(FFTSize + 2 - DataCarrierPositions, :) = conj(ifftBlock(DataCarrierPositions, :));
    OFDMSymbols = ifft(ifftBlock);
    OFDMSymbols = OFDMSymbols(1:length(OFDMPositions), :);
    OFDMSymbols = [OFDMSymbols(end - CPLength / 2 + 1:end, :); OFDMSymbols; OFDMSymbols(1:CPLength / 2, :)];
    OFDMSymbols = reshape(OFDMSymbols, [], 1);
