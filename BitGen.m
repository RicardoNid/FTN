function bits = BitGen(seed)
    global bitNumber
    global tblen
    bits = randint(bitNumber, 1, 2, seed);
    bits(length(bits) - tblen:length(bits)) = 1;
