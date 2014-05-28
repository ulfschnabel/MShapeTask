function ret = chanmax(data, log)

maxv(1) = max(max(smooth(nanmean(data(:,log.Targetpos == 1) , 2), 11)));
if log.Ndistractors > 0
    maxv(2) = max(max(smooth(nanmean(data(:,log.Distractorpos == 1) , 2), 11)));
end
if log.Ndistractors > 1
    maxv(3) = max(max(smooth(nanmean(data(:,log.Randpos == 1) , 2), 11)));
end


ret = max(maxv);

