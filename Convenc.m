function [coded] = Convenc(bits)
    global trellis % 卷积编码采用的参数见参数文件
    coded = convenc(bits, trellis); % 卷积编码
