function Symbols = PowerOnOff(Symbols)
    % ��PowerOn/Off����д�ɺ���,��Ҫ����Ϊ������Ӳ���϶�Ӧ��ͬ�Ķ���ģ��
    % ����ʹ��DFX�������ʵ��
    global SToPcol
    global PowerOn
    load('./data/power_alloc.mat'); % ���ʷ���,ѵ��ģʽ����ջ���������Ϣ֮һ,power_alloc�ߴ�1*224

    for i = 1:SToPcol

        if PowerOn == 1
            Symbols(:, i) = Symbols(:, i) .* sqrt(power_alloc');
        else
            Symbols(:, i) = Symbols(:, i) ./ sqrt(power_alloc');
        end

    end
