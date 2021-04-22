%  // ======================================================================
%  //  Jinan University
%  //  @Author: JiZhou CanyangXiong
%  //  @Last Modified time: 2021-03-05
%  //  @description: Éú³ÉFTN·ûºÅ
%  // ======================================================================
function [OFDMSymbols, bitsPerFrame] = CreateOFDMSymbols(OFDMParameters, cir)
    on = OFDMParameters.on;

    %% Random BitGen
    bits = BitGen(cir);
    bitsPerFrame = bits;

    convCodedMsg = Convenc(bits);
    interleavedMsg = Interleave(convCodedMsg);
    ifftBlock = DynamicQammod(interleavedMsg, on, cir);
    OFDMSymbols = IFFT(ifftBlock);
