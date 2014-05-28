%% Get signal to noise ratio for all blocks and channels in a tank using correct trials

load('montmap')

folder = 'E:\MonkeyData\Reward';
datadir = dir('E:\MonkeyData\Reward');
tanklist = {};
for i = 3:length(datadir)
   if datadir(i).isdir
       tanklist = [tanklist, {datadir(i).name}];
   end
end

 alldata = {};

for i = 10:length(tanklist)
    blocks = {};
    tankdir = dir(['E:\MonkeyData\Reward\' tanklist{i}]);
    for j = 3:length(tankdir)
        if tankdir(j).isdir
            blocks = [blocks, {tankdir(j).name}];
        end
    end
    n = 1;
    for j = 1:length(blocks)
        clear EVENT
        EVENT.Mytank = [folder '\' tanklist{i}];
        EVENT.Myblock = blocks{j};
        EVENT = Exinf4(EVENT);
        
        if isfield(EVENT, 'Trials') && isfield(EVENT.Trials, 'correct')
            if sum(EVENT.Trials.correct) > 50
                
                EVENT.Triallngth =  0.7;
                EVENT.Start =      -0.2;
                EVENT.type = 'strms';
                EVENT.Myevent = 'Envl'; 
                tmpdata = Exd4(EVENT, EVENT.Trials.stim_onset(EVENT.Trials.correct == 1));
                tmpdata = tmpdata(montmap');
                tmpdata = cellfun(@(x) mean(x, 2), tmpdata, 'Un', 0);
                alldata(i, n) = {tmpdata};
                n = n + 1;
            end
        end
    end
end

sigdif = [];
c = 1;
for i = 1:size(alldata, 1)
   for j = 1:sum(cellfun(@isempty, alldata(i, :)) == 0)
       sigdif(:, c) = cellfun(@testResponse, alldata{i, j});
       c = c + 1;
   end
   sigdif(:, c) = 0.5;
   c = c + 1;
end

imagesc(sigdif)