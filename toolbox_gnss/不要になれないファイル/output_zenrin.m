function output_zenrin(file,data)
%-------------------------------------------------------------------------------
% Function : �[�������t�H�[�}�b�g�o��
% 
% [argin]
% file : �t�@�C����
% data : n�~9 �G�|�b�N���� (Y,M,D,H,M,S, lat,lon,Ell.H)
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% S.Fujita: Jan. 25, 2008
%-------------------------------------------------------------------------------

% �t�@�C���I�[�v��
%--------------------------------------------
fp=fopen(file,'w');

% NaN�����O
%--------------------------------------------
i=find(~isnan(data(:,7)));
data=data(i,:);

% POSITION
%--------------------------------------------
pos=data(:,7:9);

fprintf(fp,'�o�x, �ܓx\n');
for n=1:size(pos,1)
	fprintf(fp,'%15.9f, %15.9f\n',pos(n,2),pos(n,1));
end
fclose('all');
