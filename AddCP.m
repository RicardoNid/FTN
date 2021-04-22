function bitsWithCP = AddCP(bits)
    global CPLength;
    bitsWithCP = [bits(end - CPLength / 2 + 1:end); bits; bits(1:CPLength / 2)];
