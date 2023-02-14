clear
close all

%% Where are the excitability files to be analyzed?

% Folder = './CompressedData';
% 
% 
% lightCond = 'LIGHTTEST_';
% excitCond = 'EXC_';

excitStepDur = 0.25; %250ms step for excitability so divide spike count by 0.25 to get Hz
threshold = 0; %mV default: 0mV
%% Variables
filenames = ['111522_S1C2_Compressed.mat'; '111522_S2C1_Compressed.mat'; '111522_S2C4_Compressed.mat'; '112122_S1C1_Compressed.mat'; '112122_S1C2_Compressed.mat'];

inten = [-.1 .05 .1 .15 .2 .25 .3 .35 .4];
allSpikes = zeros(length(inten), 1);
[rows cols] = size(filenames);
for i = 1:rows
    data = load(['./CompressedData/' filenames(i, :)]);


    % 
    % light_filt_window = 50;   %for medfilt1 on the mean lightTraces
    % LIGHT_STD_THRESHOLD = 5;
    % lightTraceWind = 2200;
    % indexLeft = 3000; %in points for light evoked area under curve

    targetIntensities = data.CondInten;
    numIntensities = length(targetIntensities);

    trace1 = data.CH1{1};
    trace2 = data.CH1{2};

    if length(trace1) == 10000
        excitTraces = trace1;
    else
        excitTraces = trace2;
    end

    WAIT = 0;
    SELECT = 1;

    %% Excitability Analysis
    sampleRate = .1;
    dt = sampleRate * (1/1000); %Assume sample interval in ms
    t = dt:dt:dt*length(excitTraces);
    StimTime = [200 460]; %in ms Stimulation only happened until 4500 but we added before to acount for spikes that start right at the end and only reach threshold after the window is "closed"
    stimTime = StimTime(1)/sampleRate:StimTime(end)/sampleRate; %in ms Stimulation only happened until 4500 but we added before to acount for spikes that start right at the end and only reach threshold after the window is "closed"
    DecayTime =(1970:4470);
    restingVm = zeros(numIntensities,1);
    for traceLoop = 1:numIntensities
        currentIntensity = targetIntensities(traceLoop);
        restingVm(traceLoop,:) = mode(excitTraces(traceLoop,:));



        % Caculate SpikeInfo
        [spikePeak,spikePeakInd] = findpeaks(excitTraces(traceLoop,stimTime),'MinPeakHeight',threshold);
        spikePeakInd = (spikePeakInd+stimTime(1))*sampleRate; %to account for the silent period before we stimulate and for sampling rate
        spikeNum(traceLoop,:) = length(spikePeakInd);
        warning off

        currentIndex = find(targetIntensities == currentIntensity);
        IOLine(currentIndex) = length(spikePeakInd);

        %Calculate Adaptation Index and ISI
    end

    %%
    %All the traces
    plot(t, excitTraces)
    legend(string(data.CondInten))
    xlabel('Time(s)')
    ylabel('Voltage(mV)')
    title(['Excitability Curve of ' filenames(i, :)])

    %pause(5)
    waitforbuttonpress
    %Firing rate 

    for i = 1:length(targetIntensities)
        index = inten == targetIntensities(i);
        allSpikes(index) = allSpikes(index) + spikeNum(i);
    end

    allSpikes(1) = 0;


end
allSpikes = allSpikes/5; %Average across cells
allSpikes = allSpikes/4; %Average across time
plot(inten, allSpikes, '-o', 'MarkerSize', 20)
xlabel("Time(s)")
ylabel("Firing Frequency spikes/second")
title('Firing rate for n = 5 cells')