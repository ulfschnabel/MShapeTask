function Shape = cgShape( varargin )

%Generate shape display
%
%Ulf Schnabel, 03-2014
%Vision and Cognition

if nargin > 0
    In = varargin{1};
    if isstruct(In) %is this a random pattern
        Shape = In;
        
        if nargin == 3 && strcmp(varargin{2}, 'sprite')
            Id = varargin{3}; %this is the id of the stimulus object
            cgmakesprite(Id, 1024, 768, 1, 1, 1) %setdimensions and color to white
            cgsetsprite(Id)
            Shape = plotShape(Shape, Id);
            cgsetsprite(0)
            Shape.isLoaded = true;
            return
        elseif  nargin == 3 && strcmp(varargin{2}, 'D')
            Id = varargin{3}; %this is the id of the stimulus object
            cgmakesprite(Id, 1024, 768, 1, 1, 1) %setdimensions and color to white
            cgsetsprite(Id)
            Shape = plotShape(Shape, Id);
            cgsetsprite(0)
            Shape.isLoaded = true;
            cgflip(0.5, 0.5, 0.5);
            cgdrawsprite(Id, 0, 0);
            cgflip(0.5, 0.5, 0.5);
            return
        elseif  nargin == 3 && strcmp(varargin{2}, 'E')
            prompt = {'RF center x(px)', 'RF center y(px)', ...
                'num inner circle',    'num outer circle', 'Shape size', 'Targets', 'Distractors', '3 Positions', 'Orientation (1 or 2)'};
            
            dlg_title = 'Edit parameters of shape display';
            num_lines = 1;
            def = {num2str(Shape.RF(1)),num2str(Shape.RF(2)),num2str(Shape.NIn), num2str(Shape.NOut), num2str(Shape.Size), mat2str(Shape.Targets ), mat2str(Shape.Distractors), mat2str(Shape.Targetpos), num2str(Shape.Orientation)};
            answer = inputdlg(prompt,dlg_title,num_lines,def);
            

            Shape.Randdistractors = 1:length([Shape.Randdistractors Shape.Targets Shape.Distractors]);
            
            Shape.Size = str2double(answer{5});
            Shape.RF(1) = str2double(answer{1});
            Shape.RF(2) = str2double(answer{2});
            Shape.NIn= str2double(answer{3});
            Shape.NOut = str2double(answer{4});
            Shape.Targets = str2num(str2mat(answer{6}));
            Shape.Distractors = str2num(str2mat(answer{7}));
            Shape.Targetpos = str2num(str2mat(answer{8}));           
            Shape.Orientation = str2double(answer{9});
            col = uisetcolor(Shape.col);
            Shape.col = col;
            Shape.isLoaded = false; %true when a sprite is made for this Shape
            
            Shape.Randdistractors([Shape.Targets Shape.Distractors]) = [];
            
            return
        end
        
    elseif isnumeric(In) && length(In) == 4 %is this the receptive field location
        RF = In;
        Shape.RF = RF;
    else
        disp('Error, Not a valid input')
        return
    end
    
    if nargin > 1
        In = varargin{2};
        if isscalar(In) && In > 0
            if mod(In, 2) == 0 %number > 0 and dividable by 2
                Shape.SqSz = In;
            else
                Shape.SqSz = In + 1;
            end
        else
            disp('Error, Square size should be a even number greater than zero')
            return
        end
    else
        Shape.SqSz = 6;    %square size, 30px/deg, 5cycles /deg=>
    end
    
    col = uisetcolor([0.5 0.5 0.5]);
    Shape.col = col;
    Shape = newShape(Shape);
    
else
    Shape = struct;  %new curve
    %Shape.RF = [100 100 30 30]; %arbitrary value
    %Shape.SqSz = 6;         %square size, 30px/deg, 5cycles /deg=>
    
    prompt = {'RF center x(px)', 'RF center y(px)', ...
        'num inner circle',    'num outer circle', 'Shape size', 'Targets', 'Distractors', '3 Positions', 'Orientation (1 or 2)'};
    
    dlg_title = 'Input parameters for shape display';
    num_lines = 1;
    def = {'100','0','6', '12', '120', '7 45', '35 48', '1 3 5', '1'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    
    Shape.Size = str2double(answer{5});
    Shape.RF(1) = str2double(answer{1});
    Shape.RF(2) = str2double(answer{2});
    Shape.NIn= str2double(answer{3});
    Shape.NOut = str2double(answer{4});
    Shape.Targets = str2num(str2mat(answer{6}));
    Shape.Distractors = str2num(str2mat(answer{7}));
    Shape.Targetpos = str2num(str2mat(answer{8}));
    Shape.Orientation = str2double(answer{9});
    col = uisetcolor([0.5 0.5 0.5]);
    Shape.col = col;
    Shape.isLoaded = false; %true when a sprite is made for this Shape

    [fileName, pathName, filterIndex] = uigetfile('*.mat', 'MultiSelect', 'off');
    
    load([pathName fileName]);
    for i = 1:length(goodhalfcirc)
        %         if (round(rand(1)) || i == Shape.Targets(2) || i == Shape.Distractors(2)) && ~(i == Shape.Targets(1) || i == Shape.Distractors(1))
        %             Shape.stimuli(i) = {imrotate(MakeShapeImage(goodhalfcirc{i}, Shape.Size, 5), 180)};
        %             Shape.orientation(i) = 2;
        %         else
        %             Shape.stimuli(i) = {MakeShapeImage(goodhalfcirc{i}, Shape.Size, 5)};
        %             Shape.orientation(i) = 1;
        %         end
        Shape.stimuli(2, i) = {imrotate(MakeShapeImage(goodhalfcirc{i}, Shape.Size, round(Shape.Size/25)), 180)};
        Shape.stimuli(1, i) = {MakeShapeImage(goodhalfcirc{i}, Shape.Size, round(Shape.Size/25))};
    end
    Shape.Randdistractors = 1:length(goodhalfcirc);
    Shape.Randdistractors([Shape.Targets Shape.Distractors]) = [];
end

end

function Shape = plotShape(Shape, Id)

y = Shape.RF(2);
if Shape.Orientation == 1
    x = Shape.RF(1) + floor(Shape.Size*0.75*0.5);
else
    x = Shape.RF(1) - floor(Shape.Size*0.75*0.5);
end
[t, r] = cart2pol(y , x);

n = 0;
for i = t:2*pi/Shape.NIn:2*pi-(2*pi/Shape.NIn)+t
    n = n + 1;
    Shape.gridx(n) = round(sin(i) * r);
    Shape.gridy(n) = round(cos(i) * r);
end
for i = t:2*pi/Shape.NOut:2*pi-(2*pi/Shape.NOut)+t
    n = n + 1;
    Shape.gridx(n) = round(sin(i) * 2 * r);
    Shape.gridy(n) = round(cos(i) * 2 * r);
end
global Par
if ~isfield(Par, 'Ndistract')
    prompt = {'Target (1 or 2)', 'Distractor (1 or 2)', 'Number of Distractors', 'Targetpos', 'Distractorpos'};
    dlg_title = 'No Par, so please choose';
    num_lines = 1;
    def = {'1','1','17', '1', '2'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    Par.Target = str2double(answer{1});
    Par.Distractor = str2double(answer{2});
    Par.Ndistract = str2double(answer{3});
    Par.Targetpos = str2double(answer{4});
    Par.Distractorpos = str2double(answer{5});
end

tdpos = [Shape.Targetpos(Par.Targetpos), Shape.Targetpos(Par.Distractorpos)];
if Par.Ndistract > 0
    typevec = [Shape.Targets(Par.Target) Shape.Distractors(Par.Distractor) randsample(Shape.Randdistractors, Par.Ndistract-1,  0)];
    if Par.Ndistract <= Shape.NIn - 1;
        distpos = 1:Shape.NIn;
        distpos(tdpos) = [];
        distpos = randsample(distpos, Par.Ndistract-1, 0);
    else
        distpos = 1:Shape.NOut+Shape.NIn;
        distpos(tdpos) = [];
        distpos = randsample(distpos, Par.Ndistract-1, 0);
    end
    posvec = [tdpos distpos];
else
    posvec = tdpos(1);
    typevec = Shape.Targets(Par.Target);
end
base = zeros(1024, 768);
ori = Shape.Orientation;
spriten = 100;

%Draw all shapes into current sprite
cgalign('c', 'c')
for i = 1:length(typevec)
    spriten = spriten + 1;
    
    [xsize ysize] = size(Shape.stimuli{ori, typevec(i)});
    
    scalefactor = ysize/Shape.Size;
    
    gb = reshape(Shape.stimuli{ori, typevec(i)},xsize*ysize,1);
    gb = [gb,gb,gb];
    cgloadarray(spriten,xsize,ysize,gb,xsize,ysize)
    cgtrncol(spriten,'w')
    cgdrawsprite(spriten,Shape.gridx(posvec(i)) ,Shape.gridy(posvec(i)))%, round(xsize * scalefactor), round(ysize * scalefactor))
end
cgalign('c', 'c')
% pattern = double((base > 0))* Shape.col(1);
%
% [xsize ysize] = size(pattern);
%
% pattern = double(pattern == 0);
%
% gb = reshape(pattern,xsize*ysize,1);
% gb = [gb,gb,gb];
% cgloadarray(Id,xsize,ysize,gb,xsize,ysize)
cgtrncol(Id,'w')

end

function base = MakeShapeImage(result, size, thickness)

x = result(:,1);
y = result(:,2);

rangex = range(x);

x = x * 0.75/rangex;

x = round(x*size);
y = round((y*size));

sizex = range(x);
sizey = range(y);

sizediff = sizey - sizex;
base = zeros(sizex + thickness, sizey+thickness);

if ~sum(isnan(x)) && ~sum(isnan(y))
    
    for l = 1:length(x)
        % %     dir = null([x(l-1) y(l-1)] - [x(l+1) y(l+1)]);
        % %     dirtocenter = [x(l) - 100, y(l) - 100];
        % %     for s = 0:0.1:thickness-1
        % %         step = round([x(l) y(l)] + dir'*s);
        % %         if ~sum(step < 1)
        % %             base(step(1), step(2)) = 1;
        % %         end
        % %     end
        base(x(l)+ceil(thickness/2), y(l)+ceil(thickness/2)) = 1;
    end
end
h = ones(ceil(thickness/2));
base = filter2(h, base);
base = double(base == 0);
end