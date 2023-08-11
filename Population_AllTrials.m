%Population. All Trials
clear;
clc;

%Choose session
sess = input('Enter Session #: ');

%LIST OF CELLS TO ANALYZE
cool = [7,12,17,19,24,27,31,33,35,43,48, 5,36];

%LOAD DATA
load('20230422.mat');

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

endtrial = 1;

filesDir = 'C:\Users\RBU-DevV2\Documents\MATLAB\DualBox\20230422AllSpikes\';
spikefiles = dir([filesDir 'spike' '*cl*' '.mat']);

%Define Figure
figtitle = ['Population_AllTrials Session #', num2str(sess)];
figure('Name', figtitle);
set(gcf, 'WindowState', 'maximized');

%iterate through each cell
for numfile = 1:length(spikefiles)
    filename = spikefiles(numfile).name;
    load(fullfile(filesDir,filename));
   
    %define variables
    session = sess;
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
    subplot(9, 6, numfile);
    hold on;
    
    %--label each row with session #
    text(-0.15, 0.5, sprintf('cell #%d', numfile), ...
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
    
    %highlight titles
    if ismember(numfile, cool)
        title('All trials', 'Color', 'green');
    else
        title('All trials');
    end

    %label raster plot
    line([lineX, lineX], ylim, 'Color', lineColor, 'LineWidth', 1);
    yticks([]);
    xlabel('Trial Elapsed Time (ms)');
    hold off


    %clear('dataTable');
end
