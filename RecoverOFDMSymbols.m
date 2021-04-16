%  // ======================================================================
%  //  Jinan University
%  //  @Author: JiZhou CanyangXiong
%  //  @Last Modified time: 2021-03-05      
%  //  @description: 补零，做N-FFT
%  // ======================================================================
function recoveredOFDMSymbols = RecoverOFDMSymbols(recvOFDMSignal, OFDMParameters)

DataCarrierPositions = OFDMParameters.DataCarrierPositions;
OFDMPositions= OFDMParameters.OFDMPositions;
FFTSize = OFDMParameters.FFTSize;
CPLength = OFDMParameters.CPLength;
OFDMSymbolNumber = OFDMParameters.OFDMSymbolNumber;
recvOFDMSignal = reshape(recvOFDMSignal, [], OFDMSymbolNumber*2); 
recvOFDMSignal = recvOFDMSignal(CPLength/2+1:end-CPLength/2, :);
dataLen=length(OFDMParameters.DataCarrierPositions);%186
%200*2048,94~107置零（复数）第一项1~93，第二项，中间补零，为FFT做准备，第三项，94~186填入[108:1:200]
%复数
% recvOFDMSignal = [recvOFDMSignal(1:dataLen/2,:);zeros(FFTSize-dataLen,OFDMSymbolNumber*2);recvOFDMSignal(dataLen/2+1:dataLen,:)];
%实数
recvOFDMSignal_interp = zeros(FFTSize,OFDMSymbolNumber*2);
recvOFDMSignal_interp(1:length(OFDMPositions),:)= recvOFDMSignal; 
recvOFDMSignal = recvOFDMSignal_interp;

recvASKSymbols = fft(recvOFDMSignal); 
dataASKSymbols = recvASKSymbols(DataCarrierPositions, :); 
recoveredOFDMSymbols= dataASKSymbols; 
% 