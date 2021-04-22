%  // ======================================================================
%  //  Jinan University
%  //  @Author: JiZhou CanyangXiong
%  //  @Last Modified time: 2021-03-05
%  //  @description: 20个子帧组成一个大帧，每个子帧的数据要求不一样，所以seed不一样，通过cir去控制
%  // ======================================================================
function OFDMFrame = OFDMBigFrameGenerator(OFDMParameters)
    bitsAllFrame = []; % 装载自己发射机处理前的帧
    OFDMBigFrame = []; % 装载发射机处理后的帧

    for cir = 1:20
        [OFDMSmallFrame, bitsPerFrame] = OFDMFrameGenerator(OFDMParameters, cir);
        bitsAllFrame = [bitsAllFrame; bitsPerFrame];
        OFDMBigFrame = [OFDMBigFrame, OFDMSmallFrame];
    end

    OFDMFrame = reshape(OFDMBigFrame, [], 1);

    save './data/bitsAllFrame' bitsAllFrame
end
