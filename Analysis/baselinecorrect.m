function data = baselinecorrect(data, time)

rdata = reshape(data, size(data, 1) * size(data, 2), 1);

z = zscore(rdata);

rdata(z > 3) = NaN;

data = reshape(rdata, size(data, 1), size(data, 2));

baseline = nanmean(nanmean(data(time < 0, :), 2));

data = data - baseline;
