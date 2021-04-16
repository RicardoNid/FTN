%  // ======================================================================
%  //  Jinan University
%  //  @Author: JiZhou CanyangXiong
%  //  @Last Modified time: 2021-03-05
%  //  @description: 计算各子载波SNR
%  // ======================================================================
function SNR = SNRLocation(recoveredSymbols, transmittedSymbols, OFDMParameters)
    global SubcarriersNum
    %  length(OFDMParameters.DataCarrierPositions);
    recoveredSymbols = reshape(recoveredSymbols, SubcarriersNum, []);
    transmittedSymbols = reshape(transmittedSymbols, SubcarriersNum, []);
    SNR = zeros(SubcarriersNum, 1);
    % SNRdB = zeros(SubcarriersNum,1);

    for i = 1:SubcarriersNum
        SNR(i) = sum(abs(transmittedSymbols(i, :)).^2) / sum(abs(recoveredSymbols(i, :) - transmittedSymbols(i, :)).^2);
        %   SNRdB(i) = 10*log10(SNR(i));
    end

    %  // ======================================================================
    %  传入Chow算法里的SNR是取dB之前，这里画的每个子载波对应的SNR是取dB后
    % figure; plot(SNRdB);
    % xlabel('subcarrier');
    % ylabel('SNRdB');
    %  // ======================================================================
end
