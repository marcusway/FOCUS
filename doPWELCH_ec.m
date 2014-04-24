function doPWELCH_ec(varargin)

%% INFO

% UPDATED 2/1/13

% The electrodes in the settings.ROI regions are now ordered in ascending
% order, i.e, 

% OLD:                                  NEW:
% settings.ROI.RF = [4, 124, 117];               settings.ROI.RF = [4, 117, 124]

% More importantly, the code went from being pretty to being gross.  
% I've added new subfolders for average and individual electrode PSDs
% in each subject's ####_matfiles and ####_textfiles folder.  The data
% saved in the average PSD ####_avg_psds are mean PSDs for each region.  
% those saved in the ####_ind_electrode_psds folder are 513x3 matrices
% where each column is a PSD for an electrode in the region indicated by
% the file title.  

% UPDATED 1/10/13

% Instead of having the sampling frequency hard-coded in,
% this version gets each subject's sampling frequency  
% from the respective subject's Net Station file, 
% which is of the form ADHD_####.fhp.flp.s.cr.ref.mat

% UPDATED 1/9/13

% Changed the frontal region electrodes to 
% reflect the FOCUS electrodes being used in the
% FOCUS montage in Net Station.  

% OLD:                                      NEW:

% settings.ROI.RF = [124, 9, 122];                   settings.ROI.RF = [4, 124, 117];
% settings.ROI.LF = [22, 33, 24];                    settings.ROI.LF = [28, 24, 19];

% UPDATED 1/7/13

% Function changed to use the new looppwelch function
% instead of the old looppwelchmas_250 function. 

% Left and right used to be reversed but are now fixed.  

% Introduced settings.ROI struct to iterate over instead of using chunks
% of code for looppwelch

%UPDATED 11/12/12

% This script has been changed so that the power spectral
% density is no longer converted to decibels, and this fact
% is reflected in the file names, which now start w/ 'PSD' 
% instead of 'log'

%% Code

load('settings')
settings

for j = 1:nargin
    
    % organize the files into appropriate folders
    [subDir, matFolder, txtFolder] = organize(varargin{j});
    
    % load the data using get_big_data function, which works for big files
    file = fullfile(subDir,txtFolder,[settings.FILE_PREFIX, subDir, 'ecr.txt']); %determines name of file from subjid

    try
    [data, ~, ~] = get_big_data(file); %import the file
    catch me
        problem = me.message;
        disp(['MatLab is having trouble reading in the text file, ADHD_', subDir, 'ecr.txt.  Make sure that file is in the subject''s directory in the textfiles folder']);
        return
    end
    
    % Get the sampling rate from file
    load(fullfile(subDir, matFolder, [settings.FILE_PREFIX, subDir, settings.MAT_FILE_EXTENSION]), 'samplingRate');

    
    % tell the user how many channels there are and the collection sampling
    % rate
    dimensions = size(data);
    disp(['There were ' num2str(dimensions(1)) ' channels for subject ' subDir ' and ' num2str(dimensions(2)) ' timepoints.']);
    disp(['The sampling rate was ', num2str(samplingRate), 'Hz.']);
    
    % make new folders in which to save their individual electrode /
    % averaged psds
    if ~exist(fullfile(subDir,matFolder,[subDir settings.AVG_PSD_FOLDER_SUFFIX]), 'dir')
        mkdir(fullfile(subDir,matFolder),[subDir settings.AVG_PSD_FOLDER_SUFFIX]);
    end
    
    if ~exist(fullfile(subDir,txtFolder,[subDir settings.AVG_PSD_FOLDER_SUFFIX]), 'dir')
        mkdir(fullfile(subDir,txtFolder),[subDir settings.AVG_PSD_FOLDER_SUFFIX]);
    end
    
    if ~exist(fullfile(subDir, matFolder, [subDir settings.IND_PSD_FOLDER_SUFFIX]), 'dir')
        mkdir(fullfile(subDir, matFolder),[subDir settings.IND_PSD_FOLDER_SUFFIX]);
    end
    
    if ~exist(fullfile(subDir, txtFolder,[subDir settings.IND_PSD_FOLDER_SUFFIX]), 'dir')
        mkdir(fullfile(subDir, txtFolder),[subDir settings.IND_PSD_FOLDER_SUFFIX]);
    end
    
    
    % calculate & save the average power spectral density for each FOCUS region
    for region = 1:length(settings.REGIONS)
        
        % use looppwelch to get averages and a matrix with individual
        % electrode PSDs as columns
        [Pxx_matrix, PSD, F] = looppwelch(data, settings.ROI.(settings.REGIONS{region}),samplingRate, settings);
        
        % save the regional averaged PSDs
        save(fullfile(subDir,matFolder,[subDir, settings.AVG_PSD_FOLDER_SUFFIX],[subDir,'_PSDec', settings.REGIONS{region},'_mean']), 'PSD');
        csvwrite(fullfile(subDir,txtFolder,[subDir, settings.AVG_PSD_FOLDER_SUFFIX],[subDir,'_PSDec', settings.REGIONS{region}, '_mean.txt']),PSD);
        
        % save the individual electrodes as a 513x3 matrix for each region(1 column per
        % electrode)  in .mat files.  The specific electrode numbers won't
        % be included as headers here, but we know that the columns
        % (electrodes) are ordered by increasing electrode number from left
        % to right.

        save(fullfile(subDir,matFolder,[subDir settings.IND_PSD_FOLDER_SUFFIX],[subDir, '_PSDec' settings.REGIONS{region}]), 'Pxx_matrix');
        
        %open a text file for the individual electrode psds.  
        outfile = fopen(fullfile(subDir,txtFolder,[subDir settings.IND_PSD_FOLDER_SUFFIX],[subDir 'PSDec' settings.REGIONS{region} '_ind.txt']),'w');
        
        
        % Write a header row so we can identify individual channels
        % explicitly
        for electrode = 1:length(settings.ROI.(settings.REGIONS{region}))
            fprintf(outfile,'%s\t',num2str(settings.ROI.(settings.REGIONS{region})(electrode)));    
        end
        
        fprintf(outfile, '\n');

        % write the data 
        for row = 1:size(Pxx_matrix,1)
            for col = 1:size(Pxx_matrix,2)
                fprintf(outfile,'%f\t',Pxx_matrix(row,col));
            end
            fprintf(outfile,'\n');  
        end
        
        fclose(outfile);
    end
    
    % Just save the frequency vector, F, once. 
    csvwrite(fullfile(subDir,txtFolder,[subDir,'_F.txt']),F)
        
    
    % make a figure for fun.  note that the 10*log10 is just for 
    % plotting purposes and has no effect on the saved data. 
    figure();
    plot(F(2:200),10*log10(PSD(2:200)));
    xlabel('Frequency');
    ylabel('PSD');
    title(settings.REGIONS{region});
    
end


end
