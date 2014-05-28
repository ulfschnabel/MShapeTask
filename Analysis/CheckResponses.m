%Get Tanks, Blocks and Logfiles
folder = 'D:\';

monkey = 'Monty';

dates = {'20140528'};
trialpick = {'Log{i, j}.Hit > 0'}; %{'Log{i, j}.Hit == 2'};
logfiles = cell(1,1);
blocks = cell(1,1);
data = cell(1, 1);

blocks(1,:) = {'1'};


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

c1v11 = 1:25;
c1v12 = 26:45;
arrays = [repmat({'c1v11'}, 1, 25) repmat({'c1v12'}, 1, 20)];
c2 = [c1v11 c1v12];


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
            if ~isfield(tmplog.Log, 'Color')
                tmplog.Log.Color = zeros(1, length(tmplog.Log.RT));
            end
            
            Log{i, j} = tmplog.Log;
            clear EVENT
            EVENT.Mytank = tanks{i};
            EVENT.Triallngth =  0.7;
            EVENT.Start =      -0.2;
            EVENT.type = 'strms';
            EVENT.Myblock = blocks{i, j};
            EVENT = Exinf4(EVENT);
            
            %pick Trials that were either correct or error, Words are Trial
            %numbers
            if sum( Log{i, j}.Targetpos == 1) > 1
                words = Log{i, j}.Trial(eval(trialpick{i}));
                choicea1 = ismember(Log{i, j}.Trial, words);
                choicea2 = ismember(Log{i, j}.Trial, EVENT.Trials.word);
                Log{i, j} = shortenlog(Log{i, j}, choicea1 & choicea2);
                choiceb = ismember(EVENT.Trials.word, words);
                
                EVENT.Myevent = 'ENV1';
                EVENT.CHAN = c2;
                tmpdata = Exd4(EVENT, EVENT.Trials.stim_onset(choiceb));
                time = -0.2:0.7/(size(tmpdata{1,1}, 1)-1):0.5;
                %tmpdata = cellfun(@(x) filtfilt(fb,fa, x), tmpdata, 'UniformOutput' , 0);
                tmpdata = cellfun(@(x) baselinecorrect(x, time), tmpdata, 'UniformOutput' , 0);
                sigdif = cell2mat(cellfun(@(x) testResponse(x, time), tmpdata, 'UniformOutput' , 0));
                data{i, j} = tmpdata(sigdif, :);
                array{i, j} = arrays(sigdif);
            else
                data{i, j} = NaN;
                array{i, j} = NaN;
            end
        end
    end
end


for i = 1:length(dates)
    for j = 1:size(blocks(i, :), 2)
        try
            normto = cellfun(@(x) chanmax(x, Log{i, j}), data{i,j});
            
            m = 0;
            figure('color', 'white', 'position', [0 0 2475/2.3, 3525/2.3])
            for chn = min(find(strcmp(array{i, j}, 'c1v11'))):max(find(strcmp(array{i, j}, 'c1v11')))
                m = m + 1;
                ph = subplot(7,4,m);
                hold(ph,'on');
                clear h
                ENV = nanmean(data{i,j}{chn}(:,Log{i, j}.Target == 1 & Log{i, j}.Targetpos == 1) , 2)/ normto(chn);
                h(1) = plot(smooth(filtfilt(fb, fa, ENV), 11), 'color' , 'r');
                ENV = nanmean(data{i,j}{chn}(:,Log{i, j}.Target == 2 & Log{i, j}.Targetpos == 1) , 2)/ normto(chn);
                h(2) = plot(smooth(filtfilt(fb, fa, ENV), 11), 'color' , 'b');
                if max(Log{i, j}.Ndistractors) > 0
                    ENV = nanmean(data{i,j}{chn}(:,Log{i, j}.Distractor == 1 & Log{i, j}.Distractorpos == 1) , 2)/ normto(chn);
                    h(3) = plot(smooth(filtfilt(fb, fa, ENV), 11), 'color' , 'g');
                    ENV = nanmean(data{i,j}{chn}(:,Log{i, j}.Distractor == 2 & Log{i, j}.Distractorpos == 1) , 2)/ normto(chn);
                    h(4) = plot(smooth(filtfilt(fb, fa, ENV), 11), 'color' , 'm');
                end
                hold(ph,'off');
                if m == 3
                    lh = legend(h, {'Target 1', 'Target 2', 'Dist 1', 'Dist 2'});
                end
                title('Con 1 Array V1_1')
                xlim([0 550])
                ylim([-0.2 1.3])
            end
            ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
            text(0.5, 1,[monkey ' ' dates{i}, ' ', blocks{i, j}],'HorizontalAlignment' ,'center','VerticalAlignment', 'top', 'FontSize', 30)
            export_fig([ dates{i} '_' 'Array1_' blocks{i, j}])
            
            m = 0;
            figure('color', 'white', 'position', [0 0 2475/2.3, 3525/2.3])
            for chn = min(find(strcmp(array{i, j}, 'c1v12'))):max(find(strcmp(array{i, j}, 'c1v12')))
                m = m+1;
                ph = subplot(7,4,m);
                hold(ph,'on');
                clear h
                ENV = nanmean(data{i,j}{chn}(:,Log{i, j}.Target == 1 & Log{i, j}.Targetpos == 1  & Log{i, j}.Color == 0) , 2)/ normto(chn);
                h(1) = plot(smooth(filtfilt(fb, fa, ENV), 11), 'color' , 'r');
                ENV = nanmean(data{i,j}{chn}(:,Log{i, j}.Target == 2 & Log{i, j}.Targetpos == 1 & Log{i, j}.Color == 0) , 2)/ normto(chn);
                h(2) = plot(smooth(filtfilt(fb, fa, ENV), 11), 'color' , 'b');
                if max(Log{i, j}.Ndistractors > 0)
                    ENV = nanmean(data{i,j}{chn}(:,Log{i, j}.Distractor == 1 & Log{i, j}.Distractorpos == 1) , 2)/ normto(chn);
                    h(3) = plot(smooth(filtfilt(fb, fa, ENV), 11), 'color' , 'g');
                    ENV = nanmean(data{i,j}{chn}(:,Log{i, j}.Distractor == 2 & Log{i, j}.Distractorpos == 1) , 2)/ normto(chn);
                    h(4) = plot(smooth(filtfilt(fb, fa, ENV), 11), 'color' , 'm');
                end
                hold(ph,'off');
                title('Con 1 Array V1_2')
                if m == 3
                    lh = legend(h, {'Target 1', 'Target 2', 'Dist 1', 'Dist 2'});
                end
                xlim([0 550])
                ylim([-0.2 1.3])
            end
            ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
            text(0.5, 1,[monkey ' ' dates{i}, ' ', blocks{i, j}],'HorizontalAlignment' ,'center','VerticalAlignment', 'top', 'FontSize', 30)
            export_fig([dates{i} '_' 'Array2_' blocks{i, j}])
            %close all
        catch
        end
    end
end
close all

%Target vs distractor
for i = 1:length(dates)
    for j = 1:size(blocks(i, :), 2)
        if max(Log{i, j}.Ndistractors) > 0
                normto = cellfun(@(x) chanmax(x, Log{i, j}), data{i,j});
                m = 0;
                figure('color', 'white', 'position', [0 0 2475/2.3, 3525/2.3])
                for chn = min(find(strcmp(array{i, j}, 'c1v11'))):max(find(strcmp(array{i, j}, 'c1v11')))
                    m = m + 1;
                    ph = subplot(7,4,m);
                    clear h
                    hold(ph,'on');
                    ENV = nanmean(data{i,j}{chn}(:,Log{i, j}.Targetpos == 1 & Log{i, j}.Color == 0) , 2)/ normto(chn);
                    h(1) = plot(smooth(filtfilt(fb, fa, ENV), 11), 'color' , 'r');
                    if Log{i, j}.Ndistractors > 0
                        ENV = nanmean(data{i,j}{chn}(:,Log{i, j}.Distractorpos == 1) , 2)/ normto(chn);
                        h(2) = plot(smooth(filtfilt(fb, fa, ENV), 11), 'color' , 'b');
                    end
                    if Log{i, j}.Ndistractors > 1
                        ENV = nanmean(data{i,j}{chn}(:,Log{i, j}.Randpos == 1) , 2)/ normto(chn);
                        h(3) = plot(smooth(filtfilt(fb, fa, ENV), 11), 'color' , 'g');
                    end
                    hold(ph,'off');
                    title('Con 1 Array V1_1')
                    if m == 3
                        lh = legend(h, {'Target', 'Distractor', 'Randdistractor'});
                    end
                    xlim([0 550])
                    ylim([-0.2 1.3])
                end
                ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
            text(0.5, 1,[monkey ' ' dates{i}, ' ', blocks{i, j}],'HorizontalAlignment' ,'center','VerticalAlignment', 'top', 'FontSize', 30)
                export_fig([ dates{i} '_' 'TvD1_' blocks{i, j}])
                m = 0;
                figure('color', 'white', 'position', [0 0 2475/2.3, 3525/2.3])
                for chn = min(find(strcmp(array{i, j}, 'c1v12'))):max(find(strcmp(array{i, j}, 'c1v12')))
                    m = m + 1;
                    ph = subplot(7,4,m);
                    clear h
                    hold(ph,'on');
                    ENV = nanmean(data{i,j}{chn}(:,Log{i, j}.Targetpos == 1 & Log{i, j}.Color == 0) , 2)/ normto(chn);
                    h(1) = plot(smooth(filtfilt(fb, fa, ENV), 11), 'color' , 'r');
                    if Log{i, j}.Ndistractors > 0
                        ENV = nanmean(data{i,j}{chn}(:,Log{i, j}.Distractorpos == 1) , 2)/ normto(chn);
                        h(2) = plot(smooth(filtfilt(fb, fa, ENV), 11), 'color' , 'b');
                    end
                    if Log{i, j}.Ndistractors > 1
                        ENV = nanmean(data{i,j}{chn}(:,Log{i, j}.Randpos == 1) , 2)/ normto(chn);
                        h(3) = plot(smooth(filtfilt(fb, fa, ENV), 11), 'color' , 'g');
                    end
                    hold(ph,'off');
                    title('Con 1 Array V1_2')
                    if m == 3
                        lh = legend(h, {'Target', 'Distractor', 'Randdistractor'});
                    end
                    xlim([0 550])
                    ylim([-0.2 1.3])
                end
                ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
            text(0.5, 1,[monkey ' ' dates{i}, ' ', blocks{i, j}],'HorizontalAlignment' ,'center','VerticalAlignment', 'top', 'FontSize', 30)
                export_fig([ dates{i} '_' 'TvD2_' blocks{i, j}])
                %close all

        end
    end
end
close all
%Target vs distractor grand mean
for i = 1:length(dates)
    for j = 1:size(blocks(i, :), 2)
        if max(Log{i, j}.Ndistractors) > 0
            
                targetmean = reshape(cell2mat(cellfun(@(x) getchannelmean(x, Log{i, j}.Targetpos == 1 & Log{i, j}.Color == 0), data{i,j}, 'UniformOutput' , 0)), size(data{i, j}{1}, 1), size(data{i, j}, 1));
                if max(Log{i, j}.Ndistractors) > 0
                    distmean = reshape(cell2mat(cellfun(@(x) getchannelmean(x, Log{i, j}.Distractorpos == 1), data{i,j}, 'UniformOutput' , 0)), size(data{i, j}{1}, 1), size(data{i, j}, 1));
                else
                    distmean = NaN(size(data{i, j}{1}, 1), size(data{i, j}));
                end
                if max(Log{i, j}.Ndistractors) > 1
                    randmean = reshape(cell2mat(cellfun(@(x) getchannelmean(x, Log{i, j}.Randpos == 1), data{i,j}, 'UniformOutput' , 0)), size(data{i, j}{1}, 1), size(data{i, j}, 1));
                else
                   randmean = NaN(size(data{i, j}{1}, 1), size(data{i, j}));
                end
                
                chn = min(find(strcmp(array{i, j}, 'c1v11'))):max(find(strcmp(array{i, j}, 'c1v11')));
                normto = max([max(max(mean(targetmean(:, chn), 2))), max(max(mean(distmean(:, chn), 2))), max(max(mean(randmean(:, chn), 2)))]);
                figure('color', 'white', 'position', [0 0 2475/2.3, 3525/2.3])
                clear h
                hold on
                ENV = mean(targetmean(:, chn), 2);
                h(1) = plot(smooth(filtfilt(fb, fa, ENV), 11), 'color' , 'r');
                if max(Log{i, j}.Ndistractors) > 0
                    ENV = mean(distmean(:, chn), 2);
                    h(2) = plot(smooth(filtfilt(fb, fa, ENV), 11), 'color' , 'b');
                end
                if max(Log{i, j}.Ndistractors) > 1
                    ENV = mean(randmean(:, chn), 2);
                    h(3) = plot(smooth(filtfilt(fb, fa, ENV), 11), 'color' , 'g');
                end
                hold off
                title('Con 1 Array V1_1')
                    lh = legend(h, {'Target', 'Distractor', 'Randdistractor'});
                xlim([0 550])
                ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
            text(0.5, 1,[monkey ' ' dates{i}, ' ', blocks{i, j}],'HorizontalAlignment' ,'center','VerticalAlignment', 'top', 'FontSize', 30)
                export_fig([ dates{i} '_' 'GrandTvD1_' blocks{i, j}])
                m = 0;
                figure('color', 'white', 'position', [0 0 2475/2.3, 3525/2.3])
                chn = min(find(strcmp(array{i, j}, 'c1v12'))):max(find(strcmp(array{i, j}, 'c1v12')));
                normto = max([max(max(mean(targetmean(:, chn), 2))), max(max(mean(distmean(:, chn), 2))), max(max(mean(randmean(:, chn), 2)))]);
                figure('color', 'white', 'position', [0 0 2475/2.3, 3525/2.3])
                clear h
                hold on
                ENV = mean(targetmean(:, chn), 2);
                h(1) = plot(smooth(filtfilt(fb, fa, ENV), 11), 'color' , 'r');
                if max(Log{i, j}.Ndistractors) > 0
                    ENV = mean(distmean(:, chn), 2);
                    h(2) = plot(smooth(filtfilt(fb, fa, ENV), 11), 'color' , 'b');
                end
                if max(Log{i, j}.Ndistractors) > 1
                    ENV = mean(randmean(:, chn), 2);
                    h(3) = plot(smooth(filtfilt(fb, fa, ENV), 11), 'color' , 'g');
                end
                hold off
                title('Con 1 Array V1_2')
                    lh = legend(h, {'Target', 'Distractor', 'Randdistractor'});
                xlim([0 550])
                ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
            text(0.5, 1,[monkey ' ' dates{i}, ' ', blocks{i, j}],'HorizontalAlignment' ,'center','VerticalAlignment', 'top', 'FontSize', 30)
                export_fig([ dates{i} '_' 'GrandTvD2_' blocks{i, j}])
                %close all

        end
    end
end
close all
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
