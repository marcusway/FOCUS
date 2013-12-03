function [subDir,matFolder,txtFolder,eegFolder] = FOCUS_organize(subNum)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Created 9/24/12 by Marcus Way                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This function creates new                       %
%   folders if they don't already exist             %
%   and moves corresponding file types into them.   %
%   MATLAB is nice enough not to overwrite          %
%   directories that already exist. This could have %
%   been done in a loop, but it's all right as is.  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Load and display settings
    load('settings');
    
    %convert the subjid to a string  
    subDir = num2str(subNum);
    
    %make an actual directory;
    if ~exist(fullfile(subDir), 'dir')
        mkdir(subDir);
    end
    
    %and a sub-directory for .mat files
    matFolder = [subDir, settings.MAT_FOLDER_SUFFIX];
    if ~exist(fullfile(subDir, matFolder), 'dir')
        mkdir(subDir,matFolder);
    end

    %and one for .txt files
    txtFolder = [subDir, settings.TXT_FOLDER_SUFFIX];
    if ~exist(fullfile(subDir, txtFolder), 'dir')
        mkdir(subDir,txtFolder);
    end
    
    %one for .fdt files and .set files
    eegFolder = [subDir, settings.EEG_FOLDER_SUFFIX];
    if ~exist(fullfile(subDir, eegFolder), 'dir')
        mkdir(subDir,eegFolder);
    end     
    
    %make a list of the subject's .mat files in the pwd
    matfilesList = dir(fullfile([settings.FILE_PREFIX subDir '*.mat']));
    txtfilesList = dir(fullfile([settings.FILE_PREFIX,subDir,'*.txt']));
    setfilesList = dir(fullfile([settings.FILE_PREFIX,subDir,'*.set']));
    fdtfilesList = dir(fullfile([settings.FILE_PREFIX,subDir,'*.fdt']));
    
    %move the matfiles if there are any
    numMatFiles = length(matfilesList);   
    if numMatFiles > 0 %if there are any .mat files
         movefile([settings.FILE_PREFIX,subDir,'*.mat'],fullfile(subDir,matFolder));
    end
    
    %move the .txt files if there are any
    numTxtFiles = length(txtfilesList); %count the .txt files
    if numTxtFiles > 0 %if there are any .txt files
        movefile([settings.FILE_PREFIX,subDir,'*.txt'],fullfile(subDir,txtFolder));%move them
    end
    
    %same thing for .set files
    numSetFiles = length(setfilesList); %count the .set files
    if numSetFiles > 0 %if there are any .set files
        movefile([settings.FILE_PREFIX,subDir,'*.set'],fullfile(subDir,eegFolder));%move them
    end
    
    %same thing for .fdt files
    numFdtFiles = length(fdtfilesList); %count the .fdt files
    if numFdtFiles > 0 %if there are any .fdt files
        movefile([settings.FILE_PREFIX,subDir,'*.fdt'],fullfile(subDir,eegFolder));%move them
    end   
    
end