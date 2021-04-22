%  // ======================================================================
%  //  Jinan University
%  //  @Author: JiZhou CanyangXiong
%  //  @Last Modified time: 2021-03-05
%  //  @description: ²¹Áã£¬×öN-FFT
%  // ======================================================================
function recoveredOFDMSymbols = RecoverOFDMSymbols(recvOFDMSignal, OFDMParameters)

    OFDMPositions = OFDMParameters.OFDMPositions;
    OFDMSymbolNumber = OFDMParameters.OFDMSymbolNumber;
    DataCarrierPositions = OFDMParameters.DataCarrierPositions;
    FFTSize = OFDMParameters.FFTSize;
    CPLength = OFDMParameters.CPLength;

    recvOFDMSignal = reshape(recvOFDMSignal, [], OFDMSymbolNumber * 2);
    recvOFDMSignal = recvOFDMSignal(CPLength / 2 + 1:end - CPLength / 2, :);
    recvOFDMSignal_interp = zeros(FFTSize, OFDMSymbolNumber * 2);
    recvOFDMSignal_interp(1:length(OFDMPositions), :) = recvOFDMSignal;
    recvOFDMSignal = fft(recvOFDMSignal_interp);
    dataQAMSymbols = recvOFDMSignal(DataCarrierPositions, :);

    recoveredOFDMSymbols = dataQAMSymbols;
    %
