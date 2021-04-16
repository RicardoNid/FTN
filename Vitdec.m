% 维特比译码
function [decodedBits] = Vitdec(bits)
    global ConvConstLen
    global ConvCodeGen
    global tblen
    padding = ones(tblen, 1);
    trellis = poly2trellis(ConvConstLen, ConvCodeGen);
    decodedBits = vitdec(bits, trellis, tblen, 'cont', 'hard');
    % 对于尾部的错误结果,padding替换
    decodedBits = [decodedBits(tblen + 1:end); padding];
