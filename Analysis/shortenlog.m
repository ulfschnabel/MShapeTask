function log = shortenlog(log, lchoice)

field = fields(log);

for i = 1:length(field)
    if length(log.(field{i})) > 1
        log.(field{i})(~lchoice) = [];
    end
end