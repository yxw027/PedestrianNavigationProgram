function [Head] = rinexo_hread3(fid)
%---------------------------------------------------------------------
% Observation Fileのヘッダ部分読み込み関数 (rinexo_dread)
%
% [argin] 
% fid : Observation ファイルのポインタ
%
% [argout]
% Head : 各種ヘッダの情報を格納
%
% 全衛星システム, 全RINEXVer に対応 (していると思う)
% 適宜コメント追加, 書き換えを
% 詳しくは RINEX の仕様書を
%
% Ritsumeikan Univ. Kubo Lab.
% Yoshiki Shibayama  Mar. 4, 2017
%---------------------------------------------------------------------

frewind(fid);                                                               % ファイルを初期位置に戻す

%--- 格納用構造体準備
%--------------------------------------------
Head = struct('Version', [], 'Markername', [], 'tofo', [], 'tolo', [], ...
              'app_xyz', [], 'no_obs', [], 'types', [], 'dt', [], ...
              'ant_no', [], 'ant_type', [], 'ant_delta', [], ...
              'rec_type', [], 'caname', [], 'phase', [], 'glo_no', [], ...
              'glo_freq', [], 'leap', []);
Head.types = struct('gps',[],'glo',[],'gal',[],'qzs',[],'bds',[],'irn',[]);
Head.no_obs = struct('gps',0,'glo',0,'gal',0,'qzs',0,'bds',0,'irn',0);
%--- ヘッダ読み込み
%--------------------------------------------
no_obs = [];                                                                % テンポラリ

while ~feof(fid)
    temp = fgetl(fid);
    hlabel = deblank(temp(61:end));                                         % hlabel によって場合分けを行う.
    if strcmp(hlabel, 'END OF HEADER')
        break;
    end
    switch hlabel
        case 'RINEX VERSION / TYPE'
            Head.Version = sscanf(temp(1:9),'%f');
        case 'MARKER NAME'
            Head.Markername = strtrim(temp(1:60));
        case 'REC # / TYPE / VERS'
            Head.rec_type = strtrim(temp(21:40));
        case 'ANT # / TYPE'
            Head.ant_no = strtrim(temp(1:20));
            Head.ant_type = strtrim(temp(21:40));
        case 'APPROX POSITION XYZ'
            Head.app_xyz = sscanf(temp(1:42),'%f%f%f');
        case 'ANTENNA: DELTA H/E/N'
            Head.ant_delta = sscanf(temp(1:42),'%f%f%f');
        case 'SYS / # / OBS TYPES'                                          % Version 3.00~用
            sat_sys = strtrim(temp(1));
            no_obs = sscanf(temp(5:7),'%f');
            types = '';
            types = strcat(types,strrep(temp(8:60),' ',''));
            for i = 1 : floor(no_obs / 13)
                temp = fgetl(fid);
                types = strcat(types,strrep(temp(8:60),' ',''));
            end
            switch sat_sys                                                  %  Head.types.(sat_sys) で分けられるが, 扱いやすいように名前を決めておく
                case 'G'
                    Head.no_obs.gps = no_obs;
                    for i = 1:no_obs
                        Head.types.gps{i} = types(3*i-2:3*i);
                    end
                case 'R'
                    Head.no_obs.glo = no_obs;
                    for i = 1:no_obs
                        Head.types.glo{i} = types(3*i-2:3*i);
                    end
                case 'E'
                    Head.no_obs.gal = no_obs;
                    for i = 1:no_obs
                        Head.types.gal{i} = types(3*i-2:3*i);
                    end
                case 'S'
                    Head.no_obs.sbs = no_obs;
                    for i = 1:no_obs
                        Head.types.sbs{i} = types(3*i-2:3*i);
                    end
                case 'J'
                    Head.no_obs.qzs = no_obs;
                    for i = 1:no_obs
                        Head.types.qzs{i} = types(3*i-2:3*i);
                    end
                case 'C'
                    Head.no_obs.bds = no_obs;
                    for i = 1:no_obs
                        Head.types.bds{i} = types(3*i-2:3*i);
                    end
                case 'I'
                    Head.no_obs.irn = no_obs;
                    for i = 1:no_obs
                    Head.types.irn{i} = types(3*i-2:3*i);
                    end
            end
        case '# / TYPES OF OBSERV'                                          % Version 2.00~2.99用 このヘッダは2系専用
            if isempty(no_obs)
                no_obs = sscanf(temp(1:6),'%f');
                types = '';
            end
            types = strcat(types,strrep(temp(11:60),' ',''));
        case 'TIME OF FIRST OBS'
            dtime = sscanf(temp(1:43),'%6f%6f%6f%6f%6f%13f')';
            if dtime(1) < 80
                dtime(1) = dtime(1) + 2000;
            end
            Head.tofo = set_time_struct(dtime);
        case 'TIME OF LAST OBS'                                             % TIME OF LAST OBS の格納
            dtime = sscanf(temp(1:43),'%6f%6f%6f%6f%6f%13f')';
            if dtime(1) < 80
                dtime(1) = dtime(1) + 2000;
            end
            Head.tolo = set_time_struct(dtime);
        case 'SYS / PHASE SHIFT'
            sat_sys = strtrim(temp(1));
            obs_code = strtrim(temp(3:5));
            cor_app = sscanf(temp(6:14),'%f');
            %             sys_name = strcat(sat_sys,'_',obs_code);
            if ~isempty(sat_sys) && ~isempty(obs_code)
                Head.phase.(sat_sys).(obs_code) = cor_app;                      % Head.phase.(システム名 + 観測量名) に Phase shift の値を格納
            end
        case 'GLONASS SLOT / FRQ #'
            no_slo = sscanf(temp(1:3),'%f');
            sl = 0;
            g = 1;
            for i = 1 : no_slo
                Head.glo_no(g) = sscanf(temp(6+sl*7:7+sl*7),'%d');
                Head.glo_freq(g) = sscanf(temp(9+sl*7:10+sl*7),'%d');
                g = g + 1;
                sl = sl + 1;
                if rem(i,8) == 0 && i ~= no_slo
                    temp = fgetl(fid);
                    sl = 0;
                end
            end
        case 'GLONASS COD/PHS/BIS'
            Head.glo.C1C_cpb = sscanf(temp(6:13),'%f');
            Head.glo.C1P_cpb = sscanf(temp(19:26),'%f');
            Head.glo.C2C_cpb = sscanf(temp(32:39),'%f');
            Head.glo.C2P_cpb = sscanf(temp(45:52),'%f');
        case 'INTERVAL'
            Head.dt = sscanf(temp(1:10),'%f');
        case 'LEAP SECONDS'
            Head.leap = sscanf(temp(1:10),'%f');
        otherwise
    end
end

if isempty(Head.leap) && ~isempty(Head.tofo)
    Head.leap = leap_find(Head.tofo.ymdhms);
end

if Head.Version >= 2.00 && Head.Version <= 2.99                             % ver2系ではヘッダ情報からシステム毎にデータ数を特定できない
    allsys = {'gps', 'glo', 'gal', 'sbs', 'qzs', 'bds', 'irn'};             % 全システムに同じ数値，タイプを格納する
    for i = 1 : length(allsys)
        Head.no_obs.(allsys{i}) = no_obs;
        for j = 1 : no_obs
            Head.types.(allsys{i}){j} = types(2*j-1:2*j);
        end
    end
    
    
    
%     if ~isempty(strfind([Head.types.gps{:}],'CA'))                      % CAデータはCAかC1か判定．RINEX ver.2.12対応
%         Head.caname = 'CA';
%     elseif ~isempty(strfind([Head.types.gps{:}],'C1'))
%         Head.caname = 'C1';
%     else
%         Head.caname = '';
%     end
end
    