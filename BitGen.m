function bits = BitGen()
    global BitNumber
    global CurrentFrame

    global tblen
    global Seed
    bits = randint(BitNumber, 1, 2, Seed(CurrentFrame));
    bits(length(bits) - tblen:length(bits)) = 1;
