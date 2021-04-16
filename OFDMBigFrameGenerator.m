%  // ======================================================================
%  //  Jinan University
%  //  @Author: JiZhou CanyangXiong
%  //  @Last Modified time: 2021-03-05      
%  //  @description: 20����֡���һ����֡��ÿ����֡������Ҫ��һ��������seed��һ����ͨ��cirȥ����
%  // ======================================================================
function OFDMFrame = OFDMBigFrameGenerator( OFDMParameters )
on = OFDMParameters.on;
OFDMBigFrame = [];

% ���ɵ�20֡����bits��(���������������ʣ�
bitsAllFrame = [];

for cir = 1:20
    [OFDMSmallFrame, bitsPerFrame] = OFDMFrameGenerator(OFDMParameters,cir);
    OFDMBigFrame = [OFDMBigFrame,OFDMSmallFrame];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %�����ʣ�����ͼ������ʱ����������һ����֡�ܵ������ʣ���Ȼ��û��������޷���������Ƿ���ȷ
    % ���ɵ�20֡����bits��(���������������ʣ�
    if on == 0
    bitsPerFrame = bitsPerFrame';
    end
    bitsAllFrame = [bitsAllFrame;bitsPerFrame];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
end
OFDMFrame = reshape(OFDMBigFrame, [], 1);

save bitsAllFrame bitsAllFrame
end

