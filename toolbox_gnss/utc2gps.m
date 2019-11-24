function times = utc2gps(time, dtsys, leap_sec)
%-------------------------------------------------------------------------------
% utc2gps: UTCをGPSTに変換する
%
% [argin]
% time     : 時刻情報
% dtsys    : GLONASS-GPS システム時計誤差[sec]
% leap_sec : 閏秒[sec]
% 
% [argout]
% times    : 時刻情報
%
% Ritsumeikan Univ. EEE Sugimoto Lab. GPS Division
% T.Yanase: July. 18, 2009
%-------------------------------------------------------------------------------

times =num2str(datevec(datenum(time) + leap_sec/86400 + dtsys/86400));


%-------------------------------------------------------------------------------
% 以下, 外人さんのプログラムを参考につくったやつ.
% 日付をupdateすれば, 閏秒なしで実行可能 2009/08/05 by Yanase

% %% ADD NEW LEAP DATES HERE:
% stepdates = [...
%     'Jan 6 1980'
%     'Jul 1 1981'
%     'Jul 1 1982'
%     'Jul 1 1983'
%     'Jul 1 1985'
%     'Jan 1 1988'
%     'Jan 1 1990'
%     'Jan 1 1991'
%     'Jul 1 1992'
%     'Jul 1 1993'
%     'Jul 1 1994'
%     'Jan 1 1996'
%     'Jul 1 1997'
%     'Jan 1 1999'
%     'Jan 1 2006'
%     'Jan 1 2009'];
% 
% %% Convert Steps to datenums and make step offsets
% stepdates = datenum(stepdates)'; %step date coversion
% steptime = (0:length(stepdates)-1)'./86400; %corresponding step time (sec)
% 
% %% Arg Checking
% time = datenum(time); %will error if not a proper format
% 
% if ~isempty(find(time < stepdates(1)))%time must all be after GPS start date
%     error('Input dates must be after 00:00:00 on Jan 6th 1980') 
% end
% 
% %% Array Sizing
% sz = size(time);
% time = time(:);
% 
% time = repmat(time,[1 size(stepdates,2)]);
% stepdates = repmat(stepdates,[size(time,1) 1]);
% 
% %% Conversion
% times = time(:,1) + steptime(sum((time - stepdates) >= 0,2))  + dtsys/86400;
% 
% %% Reshape Output Array
% times = reshape(times,sz);
% times = datevec(times);
% times =num2str(times);


