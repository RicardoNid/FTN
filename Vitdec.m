% ά�ر�����
function [decodedBits] = Vitdec(bits)
    global ConvConstLen
    global ConvCodeGen
    global tblen
    padding = ones(tblen, 1);
    trellis = poly2trellis(ConvConstLen, ConvCodeGen);
    decodedBits = vitdec(bits, trellis, tblen, 'cont', 'hard');
    % ����β���Ĵ�����,padding�滻
    decodedBits = [decodedBits(tblen + 1:end); padding];
