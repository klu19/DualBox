%TemporalPlot
%plots spiking as a func of time
%input: bhv and spike data
%output: raster plot and PSTH

%CLEAR
clear;
clc;

%LOAD FILES
load('20230422.mat');

%open subfolder
subfolderName = '20230422AllSpikes';
cd(fullfile(pwd, subfolderName));

filename = 'spike_cl-maze192_192.3.mat'; %cell 5
%filename = 'spike_cl-maze82_82.1.mat'; %cell 48 %odor 2 selective and increase firing for session 3 (context switch)
%filename = 'spike_cl-maze50_50.5.mat'; %cell 43 %odor 1 selective and delayed suppresion between repeat and opp
%filename = 'spike_cl-maze222_222.9.mat'; %cell 36 %odor 2 swelecttive in context 2
%filename = 'spike_cl-maze222_222.8.mat'; %cell 35 %odor stimulus selective in context 1 and odor 1 selective
%filename = 'spike_cl-maze222_222.6.mat'; %cell 33 %odor stimulus selective in context1
%filename = 'spike_cl-maze222_222.14.mat'; %cell 27 %odor 1 selectve in context 1
%filename = 'spike_cl-maze222_222.11.mat'; %cell 24 %peak at 3000 drop at 4000
%filename = 'spike_cl-maze20_20.6.mat'; %cell 19 %burst around 4000 (reward)?
%filename = 'spike_cl-maze20_20.3.mat'; %cell 17 ?
%filename = 'spike_cl-maze20_20.1.mat'; %cell 12 ?
%filename = 'spike_cl-maze192_192.5.mat'; %cell 7 %odor 2 selective in context 1, odor 1 selective in context 2
%filename = 'spike_cl-maze222_222.4.mat'; %cell 31  %odor 2 selective in context 2
load(filename);

%     filename = 'spike_cl-maze50_50.5.mat';
%     folderpath  = '\Users\RBU-DevV2\Documents\MATLAB\DualBox\20230422_lec_spikes';
%     filepath = fullfile(folderpath, filename);
%     load(filepath);

%DEFINE CONSTANTS FOR VISUAL REPRESENTATION
%-Color
red = [1, 0, 0];
green = [0, 1, 0];
blue = [0, 0, 1];
alpha = 0.3;
faintred = [red, alpha];
faintgreen = [green, alpha];
faintblue = [blue, alpha];
outcomeColors = containers.Map([0, 1], {faintred, faintgreen});

%-Window size
windowsize = 10000;

%-define line representing stimulus onset
lineX = 1000;
lineColor = 'b';

%DEFINE SESSIONS BELONGING TO EACH CONTEXT
context1 = [1,2,5];
context2 = [3,4,6];


%USER 
% grouping = input('Enter grouping (1 = Standard, 2 = Repeat, 3 = Opp) : ');
% endtrial = input('Enter end trial (1 = Position, 2 = Feeder) : ');
endtrial = 1;
for grouping = 1:3

names = containers.Map([1, 2, 3], {'Standard', 'Repeat', 'Opp'});

fig_title = ['Temporal_', names(grouping)];
figure('Name', fig_title);
set(gcf, 'WindowState', 'maximized');


%iterate through each session
for session = 1:6    
    
    %define variables
    num_trials = length(obj.Sessions.TrialPosition{session,1});
    spiketimes = cellfun(@str2double, dataTable.Timestamp{1,1}) / 1000; %convert cell array to int and convert from microseconds to miliseconds
    trialstart = obj.Sessions.TrialStart{session, 2} * 1000;  %convert from seconds to miliseconds
    trialodor = obj.Sessions.TrialOdor{session, 1};
    trialoutcomes = obj.Sessions.TrialOutcome{session, 1};
    num_trials = numel(trialstart);

    %CHOOSE TRIAL END
    if endtrial == 1
        %-1. Player Position Trial End
        trialenda = obj.Sessions.TrialPosition{session,1};
        trialend = [];
    
        for i = 1:length(trialenda)
    
            trialend(i,1) = trialenda{i,1}(end,1) * 1000;
    
        end

    elseif endtrial == 2
        %-2. Feeder Time Trial End 
        trialend = obj.Sessions.TrialFeederrTimes{session,1} * 1000;
    end

    %PLOT

    %1.RASTER PLOTS

    %-all trials (no grouping)
    subplot(6, 6, 1 + (session - 1) * 6);
    hold on;
    
    %--label each row with session #
    text(-0.15, 0.5, sprintf('Session #%d', session), ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold', 'Rotation', 90);

    %--iterate through each trial in session
    for i = 1:num_trials
        
        %choose spikes the lie within trial interval
        trialspikes = spiketimes(spiketimes >= trialstart(i) & spiketimes <= trialend(i));
        
        outcome = trialoutcomes(i);

        %exclude sampling-incomplete trials
        if ~isnan(outcome) && isKey(outcomeColors, outcome)
            color = outcomeColors(outcome);
            rectangle('Position', [0, (num_trials - i + 1) - 0.5, windowsize, 1], 'FaceColor', color, 'EdgeColor', 'none');
        end
        
        %generate raster plot
        trialID = ones(size(trialspikes)) + num_trials - i;
        plot(trialspikes - trialstart(i), trialID, 'k.');
        ylim([0, num_trials + 0.5]);
        xlim([0, windowsize]);
    end
    
    %label raster plot
    title('All trials');
    line([lineX, lineX], ylim, 'Color', lineColor, 'LineWidth', 1);
    yticks([]);
    xlabel('Trial Elapsed Time (ms)');
    hold off

    %GROUPS

    if grouping == 1
        %O1 vs O2
        g1 = find(trialodor(:) == 1 & trialoutcomes(:) == 1);
        g2 = find(trialodor(:) == 2 & trialoutcomes(:) == 1);

    elseif grouping == 2
        %Repeat
        pairwise_sums = trialodor(1:end-1) + trialodor(2:end);
        ind = [0; pairwise_sums];
        
        g1 = find(ind == 2 & trialoutcomes(:) == 1);
        g2 = find(ind == 4 & trialoutcomes(:) == 1);
    elseif grouping == 3

        %OPP
        odorpair = zeros(length(trialodor),2);
        odorpair(:,1) = trialodor;
        odorpair(2:end,2) = trialodor(1:end-1);
        g1 = find(odorpair(:,1) == 1 & odorpair(:,2) == 2 & trialoutcomes(:) == 1);
        g2 = find(odorpair(:,1) == 2 & odorpair(:,2) == 1 & trialoutcomes(:) == 1);
  
    end

    %Group 1 trials
    subplot(6, 6, 2 + (session - 1) * 6);
    hold on;
    
    %define variables
    g1start = trialstart(g1);
    g1end = trialend(g1);
    g1outcomes = trialoutcomes(g1);
    num_g1 = length(g1);
    g1spikes = cell(num_g1, 1);
    
      
    %iterate through each trial in group 1
    for i = 1:num_g1

        %chose spikes that lie within trial interval
        g1spikeind = spiketimes >= g1start(i) & spiketimes <= g1end(i);
        g1spikes{i} = spiketimes(g1spikeind) - g1start(i);
        
        %exclude sampling-incomplete trials
        outcome = g1outcomes(i);
        if ~isnan(outcome) && isKey(outcomeColors, outcome)
            color = outcomeColors(outcome);
            rectangle('Position', [0, (num_g1 - i + 1) - 0.5, windowsize, 1], 'FaceColor', color, 'EdgeColor', 'none');
        end
        
        %generate raster plot
        g1ID = ones(size(g1spikes{i})) + num_g1 - i;
        plot(g1spikes{i}, g1ID, 'k.');
        ylim([0, num_g1 + 0.5]);
        xlim([0, windowsize]);
    end
    
    %label raster plot
    title('Odor 1 trials');
    line([lineX, lineX], ylim, 'Color', lineColor, 'LineWidth', 1);
    yticks([]);
    hold off

    %Group 2 trials
    subplot(6, 6, 3 + (session - 1) * 6);
    hold on;

    %define variables
    g2start = trialstart(g2);
    g2end = trialend(g2);
    g2outcomes = trialoutcomes(g2);
    num_g2 = length(g2);
    g2spikes = cell(num_g2, 1);
    
    %iterate through each trial in group 2
    for i = 1:num_g2
        
        %choose spikes that lie within trial interval
        g2spikeind = spiketimes >= g2start(i) & spiketimes <= g2end(i);
        g2spikes{i} = spiketimes(g2spikeind) - g2start(i);
        
        %exclude sampling-incomplete trials
        outcome = g2outcomes(i);
        if ~isnan(outcome) && isKey(outcomeColors, outcome)
            color = outcomeColors(outcome);
            rectangle('Position', [0, (num_g2 - i + 1) - 0.5, windowsize, 1], 'FaceColor', color, 'EdgeColor', 'none');
        end
        
        %generate raster plot
        g2ID = ones(size(g2spikes{i})) + num_g2 - i;
        plot(g2spikes{i}, g2ID, 'k.');
        ylim([0, num_g2 + 0.5]);
        xlim([0, windowsize]);
    end
    
    %label raster plot
    title('Odor 2 trials');
    line([lineX, lineX], ylim, 'Color', lineColor, 'LineWidth', 1);
    yticks([]);
    
    hold off

    %2.PSTH
    %group 1
    subplot(6, 6, 4 + (session - 1) * 6);
    binedges = 0:100:windowsize;
    
    %define variables
    g1counts = histcounts(cat(1, g1spikes{:}), binedges);
    g1rate = g1counts / 0.1; %sum of each bin dividing by duration of each bin (100 ms = 0.1 seconds)

    %plot PSTH
    bar(binedges(1:end-1), g1rate, 'hist');
    ylabel('Firing Rate (Hz)');
    title('Averaged Odor 1 PSTH');
    xlim([0, windowsize]);
    ylim([0, 250]);
    
    %group 2
    subplot(6, 6, 5 + (session - 1) * 6);
    g2counts = histcounts(cat(1, g2spikes{:}), binedges);
    g2rate = g2counts / 0.1;

    %plot PSTH
    bar(binedges(1:end-1), g2rate, 'hist');
    ylabel('Firing Rate (Hz)');
    title('Averaged Odor 2 PSTH');
    xlim([0, windowsize]);
    ylim([0, 250]);

    %3.SMOOTHED LINE GRAPH FOR BOTH GROUPS
    subplot(6, 6, 6 + (session - 1) * 6);
    %Group 1
    smoothedg1 = smooth(g1rate, 3); % Adjust the smoothing window size as desired

    %Group 2
    smoothedg2 = smooth(g2rate, 3); % Adjust the smoothing window size as desired

    %plot line graphs
    plot(smoothedg1, 'b', 'LineWidth', 2);
    hold on;
    plot(smoothedg2, 'r', 'LineWidth', 2);
    
    %set windows
    xlim([0, windowsize/100]);
    ylim([0, 250]);

    %label axis
    tickPositions = 20:20:70;
    tickLabels = 2000:2000:7000;
    xticks(tickPositions);
    xticklabels(tickLabels);
    xtickangle(0)

    ylabel('Firing Rate (Hz)');
    title('Smoothed Line Graph of Spike Histograms');

    legend('g1counts', 'g2counts');
    hold off
    
    
end

end
% %save figure
% subfolderName = 'Spatial_vs_Temporal';
% savename = [fig_title, '.png'];
% fullFilePath = fullfile(subfolderName, savename);
% 
% saveas(gcf, fullFilePath);
