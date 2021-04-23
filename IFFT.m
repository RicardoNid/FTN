function [OFDMSymbols] = IFFT(QAMSymbols)
    global IsPreamble
    global PreambleCarrierPositions
    global DataCarrierPositions
    global FFTSize
    global OFDMPositions
    global CPLength
    global SToPcol

    if IsPreamble == 1;
        ifftBlock = zeros(FFTSize, 1); % paddingΪifftBlock
        ifftBlock(PreambleCarrierPositions) = QAMSymbols;
        ifftBlock(FFTSize + 2 - PreambleCarrierPositions) = conj(QAMSymbols);
        preamble = ifft(ifftBlock); % ����ifft
        OFDMSymbols = [preamble(end - CPLength / 2 + 1:end); preamble; preamble(1:CPLength / 2)]; % ����ѭ��ǰ׺
    else
        %% ������"����"��ifftBlock
        ifftBlock = zeros(FFTSize, SToPcol); % padding
        ifftBlock(DataCarrierPositions, :) = QAMSymbols; % ����QAM����
        ifftBlock(FFTSize + 2 - DataCarrierPositions, :) = conj(ifftBlock(DataCarrierPositions, :)); % �����乲��

        OFDMSymbols = ifft(ifftBlock); % ��׼ifft
        OFDMSymbols = OFDMSymbols(1:length(OFDMPositions), :); % ��ifftBlock��ȡ��Ϣ����
        OFDMSymbols = [OFDMSymbols(end - CPLength / 2 + 1:end, :); OFDMSymbols; OFDMSymbols(1:CPLength / 2, :)]; % ����ѭ��ǰ׺
        OFDMSymbols = reshape(OFDMSymbols, [], 1); % ��->��ת��,��Ӳ���ϲ�������
    end
