clear
close all

%% Where are the excitability files to be analyzed?

% Folder = './CompressedData';
% 
% 
% lightCond = 'LIGHTTEST_';
% excitCond = 'EXC_';

%% Variables

%Choose which file to load
data = load('./CompressedData/112222_S1C1_Compressed.mat');
datainv = data.expInten'; %invert light intensity to index easier 
optoInten = datainv(:); %vectorize light intensities to index linearly with each trace

trace1 = data.CH1{1};
trace2 = data.CH1{2};

if length(trace1) == 20000
    optoTraces = trace1;
else
    optoTraces = trace2;
end

%Find the right trace

%% Excitability Analysis

sampleRate = .1;
dt = sampleRate * (1/1000); %Assume sample interval in ms
t = dt:dt:dt*length(optoTraces);

light = zeros(length(optoTraces(1, :)), 1) - 60;
light(2000:2050) = 40;
light(3000:3050) = 40;
light(4000:4050) = 40;
light(5000:5050) = 40;
light(6000:6050) = 40;

currIntensity = -1;
prevIntensity = optoInten(1);
first = 1;
n = 0;

labels = zeros(length(unique(optoInten)), 1);
uniqueI = 1;

for i = 1:length(optoInten)
    currIntensity = optoInten(i);
    labels(uniqueI) = currIntensity;
    if currIntensity == prevIntensity
        %plot(t, optoTraces(i, :), 'Color', [.7 .7 .7]) %Add a shallow trace
        n = n + 1;
        hold on
    else %At a new trace
        plot (t, mean(optoTraces(first: first + (n-1), :)), '-b', 'LineWidth', 1) %plot n-1 traces to see the average of previous intensity
        plot(t, light, 'Color', [0 0 0])
        xlabel('Time(s)');
        ylabel('Voltage(mV)');
        title('Mean trace of all intensities');
        %title(['Mean trace for EPSP for intensity of ', num2str(prevIntensity), 'mA for n = ', num2str(n) ' traces']);
        % Backtrack one i to repeat current NEW intensity
        i = i - 1;
        prevIntensity = currIntensity;
        first = i;
        n = 1;
        uniqueI = uniqueI + 1;
        hold on
        pause(1);
        %clf('reset')
    end
end

%Plot the mean of the last one
plot (t, mean(optoTraces(first: first + (n-1), :)), '-b', 'LineWidth', 1)
plot(t, light, 'Color', [0 0 0])
xlabel('Time(s)')
ylabel('Voltage(mV)')
%title(['Mean trace for EPSP for intensity of ', num2str(currIntensity), 'mA for n = ', num2str(n) ' traces'])
hold on