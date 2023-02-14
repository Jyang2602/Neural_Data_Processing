%%% Compress TAq data acquired for Jeffrey's Optogenetic training
%%% experiments
%%% Based on Compress_TAq1 and CompressTAq
%%% Modified 120722

clear all
close all

repeat = 0;

while repeat == 0;
cell = input(['Which cell?-> '], 's');    %THE CELL TO COMPRESS

ExpCond = 5; %Main condition for the experiment "Group Code" in TAq

str = sprintf('%s*.mat', cell);
Files = dir(str);
    if length(Files) ~= 0
        repeat = 1;
    else 
        disp (['No files found for cell ' cell]);
    end
end

%%% SORT BY DATE/TIME SO THAT THEY ARE READ IN ORDER
s = [Files(:).datenum].';
[dumy ind] = sort(s);
SortedFileNames =  {Files(ind).name}; % Cell array of names in order by datenum.



%INPUT EXPERIMENT INFORMATION
DIV=input(['How many days in vitro for slice-> ']);
Transfected = input(['When was slice transfected —> ']);
% TDIV=input(['How many days transfected #' num2str(c) '?']);

CondInten = str2num(input('Input CondInten as a vector; [-.1 .05 .1 .15 .2 .25 .3 -.1 -.1 -.1]', 's'));

expTrials = input(['How many trials did you run the optogenetics for —> ']);

expInten = zeros(expTrials, 10);

for n = 1:(expTrials);
    nextInten = str2num(input('Input CondInten as a vector; [-.1 .05 .1 .15 .2 .25 .3 -.1 -.1 -.1]', 's'));
    expInten(n, 1:10] = nextInten


CondCount = 0;
tracecount = 0;
cond = 1; prevcond = -99;
for j=1:size(SortedFileNames,2);
    file = SortedFileNames{j};
    fprintf('Reading %s.\n',file);
    load(file);
    pts = strfind(file,'.');
    cond = str2double(file(pts(1)+1:pts(2)-1));
    if cond~=prevcond       %detect change in conditions (e.g., Excit(#2) to Caged(#6)
        CondCount = CondCount+1;
        prevcond = cond;
        tracecount = 0;
    end
    tracecount = tracecount + 1;
    CH1{CondCount}(tracecount,:)=10*data;%%This 10 factor scales the data and places the units in mV.(really *1000/100; 100 = gain)
end

for j=1:CondCount
    figure
    imagesc(CH1{j})
end


Dir = pwd;
slashes = strfind(Dir,'/'); % '\' for pc
Dir = Dir(slashes(end)+1:end);
SaveFile = sprintf('%s_%s_Compressed.mat',Dir,cell);
save(SaveFile,'CH1','DIV','Transfected', 'CondIten', 'expInten', 'p','cell');




