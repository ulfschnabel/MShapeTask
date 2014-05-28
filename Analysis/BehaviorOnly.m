%Get Tanks, Blocks and Logfiles
folder = 'D:\';

monkey = 'Monty';

dates = {'20140527'};
trialpick = {'Log{i, j}.Hit > 0'}; %{'Log{i, j}.Hit == 2'};
logfiles = cell(1,1);
blocks = cell(1,1);
data = cell(1, 1);

blocks(1,:) = {'92'};


for i = 1:length(dates)
    tanks(i) = {[folder monkey dates{i}]};
    for j = 1:size(blocks(i, :), 2)
        if ~isempty(blocks{i, j})
            logfiles(i, j) = {[folder monkey dates{i} '\' monkey dates{i} '_B' blocks{i, j}]};
            blocks(i, j) = {['block-' blocks{i, j}]};
        end
    end
end

%Set arrays

c2v11 = 1:20;
c2v12 = 21:40;
arrays = [repmat({'c2v11'}, 1, 20) repmat({'c2v12'}, 1, 20)];
c2 = [c2v11 c2v12];


%set up filter
SF = 762.9395;
no = 2;
wn = [45 floor(SF./2)]./(SF./2);
[fb,fa] = butter(no,wn,'stop');
Hd = dfilt.df2t(fb,fa);

%Read data in

for i = 1:length(dates)

    for j = 1:size(blocks(i, :), 2)
        if ~isempty(blocks{i, j})
            tmplog = load(logfiles{i, j});
            Log{i, j} = tmplog.Log;
        end
    end
end


%Behavior
for i = 1:length(dates)
    for j = 1:size(blocks(i, :), 2)
        plotmat = [];
        for t = unique(Log{i, j}.Target)
            for p = unique(Log{i, j}.Targetpos)
                plotmat(t, p) = sum(Log{i, j}.Target == t & Log{i, j}.Targetpos == p & Log{i, j}.Hit == 2)/sum(Log{i, j}.Target == t & Log{i, j}.Targetpos == p);
            end
        end
        figure('color', 'white', 'position', [0 0 800, 600])
        clear h
        h(1) = plot(plotmat(1,:), 'bo-');
        hold on
        h(2) = plot(plotmat(2,:), 'ro-');
        hold off
        legend(h, {'Target 1', 'Target 2'})
        xlim([0.8 3.2])
        ylim([0 1])
        title(dates{i})
        set(gca, 'xtick', 1:3)
        xlabel('Target Position')
        ylabel('Performance')
        export_fig([ dates{i} '_Performance' '_' blocks{i, j}])
    end
end
close all
