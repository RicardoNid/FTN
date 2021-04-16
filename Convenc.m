function [codedBits] = Convenc(bits)
    constlen = 7;
    codegen = [171 133];
    trellis = poly2trellis(constlen, codegen);
    codedBits = convenc(bits, trellis);
