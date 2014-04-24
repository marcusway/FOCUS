% makeSettings.m
% Marcus Way 
% Created 12/3/2013

% This script sets study-specific settings to be used
% by the rest of the analysis scripts and saves these
% settings to a file named settings.mat in the working 
% directory.

%% 
clear all
close all
clc

%% Inititialize the settings struct
settings = struct;
settings.study = 'FOCUS';
disp(['Using settings for study: ' settings.study])

%% Set the regions/electrodes of interest

% These are probably going to remain the same across studies, 
% but changing them here will change the electrodes used in all
% frequency analysis scripts/functions 
settings.ROI = struct;
settings.ROI.RF = [4, 117, 124];
settings.ROI.LF = [19, 24, 28 ];
settings.ROI.RP = [85, 86, 92 ];
settings.ROI.LP = [52, 53, 60 ];
settings.ROI.O  =  [70, 75, 83 ];
settings.REGIONS = fieldnames(settings.ROI);

%% Set frequency analysis constants

settings.SAMPLING_RATE   = 250; % Desired sampling rate
settings.LOWER_LIM       = 1;   % Lowest frequency of interest
settings.UPPER_LIM       = 30;  % Highest frequency of interest
settings.NFFT            = 1024; % Size of the window for pwelch
settings.WINDOW          = hanning(1024); % Type of window for pwelch
settings.REGIONS         = {'LF','RF','LP','RP','O'};
settings.CONDITIONS      = {'eo','ec'}; % eyes open and eyes closed
settings.BANDS           = struct;
settings.BANDS.DELTA     = [1, 4];
settings.BANDS.THETA     = [5, 8];
settings.BANDS.ALPHA     = [8, 12];
settings.BANDS.BETA      = [12, 30];

%% Naming Conventions
settings.FILE_PREFIX       = 'ADHD_';
settings.SUBMNUM_FIRST_DIGIT = '4';
settings.IND_PSD_FOLDER_SUFFIX       = '_ind_electrode_psds';
settings.AVG_PSD_FOLDER_SUFFIX = '_avg_psds';
settings.MAT_FOLDER_SUFFIX = '_matfiles';
settings.TXT_FOLDER_SUFFIX = '_textfiles';
settings.EEG_FOLDER_SUFFIX = '_eeglabfiles';
settings.MAT_FILE_EXTENSION = '.fhp.flp.s.cr.ref.mat';
settings.MAT_FILE_EXTENSION_NO_DOTS = 'fhpflpscrref';
settings.NORM_FREQ = 'norm_freq';
save('settings')
