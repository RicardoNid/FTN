%  // ======================================================================
%  //  Jinan University
%  //  @Author: JiZhou CanyangXiong
%  //  @Last Modified time: 2021-03-05
%  //  @description: ��������ز�SNR
%  // ======================================================================
function SNR = SNRLocation(recoveredSymbols, transmittedSymbols)
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
    %  ����Chow�㷨���SNR��ȡdB֮ǰ�����ﻭ��ÿ�����ز���Ӧ��SNR��ȡdB��
    % figure; plot(SNRdB);
    % xlabel('subcarrier');
    % ylabel('SNRdB');
    %  // ======================================================================
end
