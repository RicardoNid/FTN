function Demodulated = DynamicQammod(recoveredBits, on, cir)
    global SubcarriersNum
    global SToPcol
    global BitsPerSymbolQAM
    global OFDMSymbolNumber
    global RmsAlloc

    if on == 1
        load('./data/power_alloc.mat');

        for i = 1:SToPcol
            recovered(:, i) = recovered(:, i) ./ sqrt(power_alloc');
        end

    else
        recoveredSymbols = reshape(recovered, [], 1);
    end
