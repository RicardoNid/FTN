function [interleavedBits] = Interleave(bits)
    depth = 32;
    bits = reshape(bits, depth, []);
    interleavedBits = [];

    for k = 1:depth
        interleavedBits = [interleavedBits, bits(k, :)];
    end

    interleavedBits = interleavedBits.';
