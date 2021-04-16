function [codedBits] = Convenc(bits)
    global ConvConstLen
    global ConvCodeGen
    trellis = poly2trellis (ConvConstLen, ConvCodeGen);
    codedBits = convenc(bits, trellis);
