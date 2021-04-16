function [OFDMSymbols] = IFFT(ifftBlock)
    DataCarrierPositions = 3:226;
    FFTSize = 512;
    OFDMPositions = sort([1 DataCarrierPositions FFTSize / 2 + 1 FFTSize + 2 - DataCarrierPositions]);
    CPLength = 20;
    %% 共轭对称
    ifftBlock(FFTSize + 2 - DataCarrierPositions, :) = conj(ifftBlock(DataCarrierPositions, :));
    % IFFT
    OFDMSymbols = ifft(ifftBlock);
    OFDMSymbols = OFDMSymbols(1:length(OFDMPositions), :);
    OFDMSymbols = [OFDMSymbols(end - CPLength / 2 + 1:end, :); OFDMSymbols; OFDMSymbols(1:CPLength / 2, :)];
    OFDMSymbols = reshape(OFDMSymbols, [], 1);
