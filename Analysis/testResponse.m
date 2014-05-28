function sig = testResponse(data, time)

        if size(data, 2) > 1
           data = nanmean(data, 2); 
        end

        RespT = find(time > 0);
        BaseT = find(time <= 0);

        Base = nanmean(data(BaseT));
        BaseS = std(data(BaseT));
        
        data = smooth(data,10);
        data = data(RespT);
        
        sm = smooth(data,30);%medfilt1
        mx = max(sm);
        Scale = mx-Base;

        %As an alternative, could take summed response-summed abckgroudn.
%         MUAmean(mapchn,n) = mean(mean(MUA))-mean(mean(MUA));

        %Is the max significantly different to the base?
        sig = mx > (Base+(3*BaseS));
        
end