function [coded] = Convenc(bits)
    global trellis % ���������õĲ����������ļ�
    coded = convenc(bits, trellis); % �������
