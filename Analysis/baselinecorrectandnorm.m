function data = baselinecorrectandnorm(data, time)

rdata = reshape(data, size(data, 1) * size(data, 2), 1);

z = zscore(rdata);

rdata(z > 2.5) = NaN;

data = reshape(rdata, size(data, 1), size(data, 2));

baseline = nanmean(nanmean(data(time < 0, :), 2));

data = data - baseline;

data = data/max(max(data));
