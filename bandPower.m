% getBandPower
% Marcus Way | marcusway23@gmail.com
% This script just runs a python script from the
% Matlab command prompt so that Terminal, with all its scariness,
% doesn't have to get involved.

%% Clear stuff
clear all;
close all;
clc;

%% Run it!
load('settings')
system(['/Users/sheridanlab/anaconda/bin/python get_band_power.py "'...
    settings.FILE_PREFIX settings.NORM_FREQ...
    '*" all_subs_band_pow.csv']);

