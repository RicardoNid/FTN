function bits = BitGen()
    global BitNumber
    global CurrentFrame
    global tblen
    global Seed
    bits = randint(BitNumber, 1, 2, Seed(CurrentFrame));
    bits(length(bits) - tblen:length(bits)) = 1; % 放弃一定数量的比特位,因为维特比译码无法得到正确的尾部
