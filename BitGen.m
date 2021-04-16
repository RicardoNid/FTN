function bits = BitGen(cir)
    global bitNumber
    global tblen
    global Seed
    bits = randint(bitNumber, 1, 2, Seed(cir));
    bits(length(bits) - tblen:length(bits)) = 1;
