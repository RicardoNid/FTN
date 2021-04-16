%  // ======================================================================
%  //  Jinan University
%  //  @Author: JiZhou CanyangXiong
%  //  @Last Modified time: 2021-03-05
%  //  @description: 20个子帧组成一个大帧，每个子帧的数据要求不一样，所以seed不一样，通过cir去控制
%  // ======================================================================
function OFDMFrame = OFDMBigFrameGenerator(OFDMParameters)
    on = OFDMParameters.on;
    OFDMBigFrame = [];

    % 生成的20帧的总bits数(用来算总体误码率）
    bitsAllFrame = [];

    for cir = 1:20
        [OFDMSmallFrame, bitsPerFrame] = OFDMFrameGenerator(OFDMParameters, cir);
        OFDMBigFrame = [OFDMBigFrame, OFDMSmallFrame];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %误码率，星座图都不画时，计算最终一个大帧总的误码率，不然就没有输出，无法检验代码是否正确
        % 生成的20帧的总bits数(用来算总体误码率）
        bitsAllFrame = [bitsAllFrame; bitsPerFrame];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end

    OFDMFrame = reshape(OFDMBigFrame, [], 1);

    save bitsAllFrame bitsAllFrame
end
