function [OFDMSymbols] = IFFT(QAMSymbols)
    global DataCarrierPositions
    global FFTSize
    global OFDMPositions
    global CPLength
    global SToPcol

    %% ������"����"��ifftBlock
    ifftBlock = zeros(FFTSize, SToPcol); % padding
    ifftBlock(DataCarrierPositions, :) = QAMSymbols; % ����QAM����
    ifftBlock(FFTSize + 2 - DataCarrierPositions, :) = conj(ifftBlock(DataCarrierPositions, :)); % �����乲��

    OFDMSymbols = ifft(ifftBlock); % ��׼ifft
    OFDMSymbols = OFDMSymbols(1:length(OFDMPositions), :); % ��ifftBlock��ȡ��Ϣ����
    OFDMSymbols = [OFDMSymbols(end - CPLength / 2 + 1:end, :); OFDMSymbols; OFDMSymbols(1:CPLength / 2, :)]; % ����ѭ��ǰ׺
    OFDMSymbols = reshape(OFDMSymbols, [], 1); % ��->��ת��,��Ӳ���ϲ�������
