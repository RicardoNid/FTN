function [OFDMSymbols] = IFFT(ifftBlock)
    global On
    global DataCarrierPositions
    global FFTSize
    global SToPcol
    global OFDMPositions
    global CPLength

    % ifftBlock = zeros(FFTSize, SToPcol); % 构造FFT数据
    % ifftBlock(DataCarrierPositions, :) = QAMSymbols;

    % if On == 1
    %     load('./data/power_alloc.mat');

    %     for i = 1:SToPcol
    %         ifftBlock(DataCarrierPositions, i) = ifftBlock(DataCarrierPositions, i) .* sqrt(power_alloc');
    %     end

    % end

    ifftBlock(FFTSize + 2 - DataCarrierPositions, :) = conj(ifftBlock(DataCarrierPositions, :));
    OFDMSymbols = ifft(ifftBlock);
    OFDMSymbols = OFDMSymbols(1:length(OFDMPositions), :);
    OFDMSymbols = [OFDMSymbols(end - CPLength / 2 + 1:end, :); OFDMSymbols; OFDMSymbols(1:CPLength / 2, :)];
    OFDMSymbols = reshape(OFDMSymbols, [], 1);
