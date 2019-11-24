function [SensorPos] = getSensor(fpcsv,time,timetag)

   %センサーからの値を発見
    [row,col] = find(fpcsv == time.day(6));
    row = row(length(row));
    col = col(length(col));
    row2 = row - 1;
    while(fpcsv(row2,col) == 0)
        row2=row2-1;
    end
    SensorMoveE = sum(fpcsv(row2+1:row-1,1));
    SensorMoveN = sum(fpcsv(row2+1:row-1,2));
    SensorMoveU = fpcsv(row2+1,3);    
%     abc = atan(SensorMoveE/SensorMoveN);
%     abcd = abc * 180/pi
    
    Radian = deg2rad(316);%120 最初52 %316
   
%    SensorMoveD = [SensorMoveE,SensorMoveN]';
    %座標の回転
    SensorMoveD = [cos(Radian),-sin(Radian);sin(Radian),cos(Radian)]*[SensorMoveE,SensorMoveN]';
    
    if(row2 ~= row - 1)
%        if(isnan(Result.ppp.pos(timetag-1,1:3)))
%            %fprintf('Sensor:ON(E:%1.1f N:%1.1f)',SensorMoveE,SensorMoveN);
%            INS(1:3) = Result.ppp.pos(timetag-2,1:3) + enu2xyz([SensorMoveE,SensorMoveN,0]',[0,0,0]')';
%        else
            fprintf('Sensor(E:%1.1f N:%1.1f)',SensorMoveD(1),SensorMoveD(2));
%            LLHKal = xyz2llh(Kalx_p(1:3)).*[180/pi 180/pi 1];
%            altitude = SensorMoveU(1) - Result.ppp.pos(timetag-1,6);


            INS(1:3) = [SensorMoveD(1),SensorMoveD(2),SensorMoveU(1)];
            %INS(1:3)=[SensorMoveE,SensorMoveN,SensorMoveU(1)];
%            ENUPOS = xyz2enu(Result.ppp.pos(timetag-1,1:3)',refl) + INS(1:3)';
%            Kalx_p(1:3) = enu2xyz(ENUPOS , refl);
            %fprintf('INSPOS:(E:%3.4f N:%3.4f U:%3.4f)',xyz2enu(Kalx_p(1:3),refl));
%        end
    else
        INS(1:3) = [0,0,0];
    end
    SensorPos = INS;
   
end

