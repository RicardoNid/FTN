%  // ======================================================================
%  //  Jinan University
%  //  @Author: JiZhou CanyangXiong
%  //  @Last Modified time: 2021-03-05
%  //  @description: 20����֡���һ����֡��ÿ����֡������Ҫ��һ��������seed��һ����ͨ��cirȥ����
%  // ======================================================================
function OFDMFrame = OFDMBigFrameGenerator()
    global CurrentFrame
    bitsAllFrame = []; % װ���Լ����������ǰ��֡
    OFDMBigFrame = []; % װ�ط����������֡

    CurrentFrame = 1;

    for cir = 1:20
        [OFDMSmallFrame, bitsPerFrame] = OFDMFrameGenerator();
        bitsAllFrame = [bitsAllFrame; bitsPerFrame];
        OFDMBigFrame = [OFDMBigFrame, OFDMSmallFrame];
        CurrentFrame = CurrentFrame + 1;
    end

    OFDMFrame = reshape(OFDMBigFrame, [], 1);

    save './data/bitsAllFrame' bitsAllFrame
end
