function [OFDMSymbols] = IFFT(QAMSymbols)
    global DataCarrierPositions
    global FFTSize
    global OFDMPositions
    global CPLength
    global SToPcol

    %% 将数据"放置"到ifftBlock
    ifftBlock = zeros(FFTSize, SToPcol); % padding
    ifftBlock(DataCarrierPositions, :) = QAMSymbols; % 放置QAM符号
    ifftBlock(FFTSize + 2 - DataCarrierPositions, :) = conj(ifftBlock(DataCarrierPositions, :)); % 放置其共轭

    OFDMSymbols = ifft(ifftBlock); % 标准ifft
    OFDMSymbols = OFDMSymbols(1:length(OFDMPositions), :); % 从ifftBlock提取信息符号
    OFDMSymbols = [OFDMSymbols(end - CPLength / 2 + 1:end, :); OFDMSymbols; OFDMSymbols(1:CPLength / 2, :)]; % 增加循环前缀
    OFDMSymbols = reshape(OFDMSymbols, [], 1); % 并->串转换,在硬件上并不进行
