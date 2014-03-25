%% Author/Contact
% Marcus Way // Boston Children's Hospital
% marcusway23@gmail.com

%% Script Info
% This is a script that takes all of the subjects with individual
% PSDs output from doPWELCH, and then looks at the frequency range
% specified by LOWER_LIM and UPPER_LIM.  For each region in each subject,
% it takes each electrode of interest, normalizes its PSD by dividing the
% value in each bin by the total power in our band of interest.  It then
% averages the normalized electrode PSDs together and outputs the new,
% averaged PSD for our region of interest to a single column in a file
% specific to the region and condition.  There will be ten new files
% written in the working directory:

% ADHD_norm_freq_eoLF
% ADHD_norm_freq_ecLF
% ADHD_norm_freq_eoRF
% ADHD_norm_freq_ecRF
% ADHD_norm_freq_eoLP
% ADHD_norm_freq_ecLP
% ADHD_norm_freq_eoRP
% ADHD_norm_freq_ecRP
% ADHD_norm_freq_eoO
% ADHD_norm_freq_ecO

%% Clear everything
close all
clear all
clc

%% INITIALIZATIONS

% Load the settings file, inform user of settings
load('settings');
settings

PSD_FILE_TAG    = '_PSD';
PSD_VARNAME     = 'Pxx_matrix';
OUT_FILE_EXTENSION = '.csv';

% Generate array of all frequencies according to our sampling rate and NFFT
f = 0:settings.SAMPLING_RATE/settings.NFFT:settings.SAMPLING_RATE/2;

% Find the indices in f that correspond to the frequencies in
% our band of interest.
pow_range = f > settings.LOWER_LIM & f < settings.UPPER_LIM;

%Make a list of all the subjects we want:
subDir = dir('4*'); % all the subject directories start with a '1'
subjects = cell(1, length(subDir));
for i = 1:length(subDir)
    subjects{i} = subDir(i).name;
end

%% MAIN LOOP

for condition = 1:length(settings.CONDITIONS)
    
    for region = 1:length(settings.REGIONS)
        filename = [settings.FILE_PREFIX settings.NORM_FREQ settings.CONDITIONS{condition} settings.REGIONS{region} OUT_FILE_EXTENSION];
        outfile = fopen(filename,'w');
        subs_with_data = {};
        data = [];
        
        for subject = 1:length(subjects)
            
            % NOTE:  This would run faster if I preallocated the data
            % and norm matrices, but this would require that calculate
            % the number of subjects with data for each condition
            % beforehand.  Something to consider, but would require a
            % little rearranging.
            
            try % If the subject file exists, open and analyze it
                load(fullfile(subjects{subject},[subjects{subject},...
                    settings.MAT_FOLDER_SUFFIX],[subjects{subject},...
                    settings.IND_PSD_FOLDER_SUFFIX],[subjects{subject},...
                    PSD_FILE_TAG,...
                    settings.CONDITIONS{condition},settings.REGIONS{region}]),...
                    PSD_VARNAME);                
            catch error % If not, catch the error, warn the user, skip to the next file
                disp(['No ' settings.CONDITIONS{condition},...
                    ' segment for subject ', subjects{subject}]);
                continue;
            end
            
            norm = [];
            for col = 1:size(Pxx_matrix,2)
                
                % Normalize each electrode's power spectrum
                curr_electrode = Pxx_matrix(:,col);
                total_power = sum(curr_electrode(pow_range));
                norm = [norm curr_electrode/total_power];
            end
            
            % Average across normalized power spectra across
            % channels in the region
            avg_norm = mean(norm,2);
            data = [data; avg_norm(pow_range)'];
            
            % Note that this subject had data for this condition
            % (only subjects who have data for the given condition
            % will be recorded in the corresponding spreadsheets).
            subs_with_data{end+1} =  subjects{subject};          
        end
        
        % keep the user informed
        disp(['File:', filename,' Num subjects: ' num2str(length(subs_with_data))]);
        
        myFreqs = f(pow_range);
        write_with_headers(data, outfile, myFreqs, subs_with_data, 'sID');
        
    end
    fclose(outfile);
end
