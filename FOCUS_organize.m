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


    %convert the subjid to a string  
    subDir = num2str(subNum);
    
    %make an actual directory;
    mkdir(subDir);
    
    %and a sub-directory for .mat files
    matFolder = [subDir, '_matfiles'];
    mkdir(subDir,matFolder);

    %and one for .txt files
    txtFolder = [subDir, '_textfiles'];
    mkdir(subDir,txtFolder);
    
    %one for .fdt files and .set files
    eegFolder = [subDir, '_eeglabfiles'];
    mkdir(subDir,eegFolder);
     
    
    %make a list of the subject's .mat files in the pwd
    matfilesList = dir(fullfile(['ADHD_',subDir,'*.mat']));
    txtfilesList = dir(fullfile(['ADHD_',subDir,'*.txt']));
    setfilesList = dir(fullfile(['ADHD_',subDir,'*.set']));
    fdtfilesList = dir(fullfile(['ADHD_',subDir,'*.fdt']));
    
    %move the matfiles if there are any
    numMatFiles = length(matfilesList);   
    if numMatFiles > 0 %if there are any .mat files
         movefile(['ADHD_',subDir,'*.mat'],fullfile(subDir,matFolder));
    end
    
    %move the .txt files if there are any
    numTxtFiles = length(txtfilesList); %count the .txt files
    if numTxtFiles > 0 %if there are any .txt files
        movefile(['ADHD_',subDir,'*.txt'],fullfile(subDir,txtFolder));%move them
    end
    
    %same thing for .set files
    numSetFiles = length(setfilesList); %count the .txt files
    if numSetFiles > 0 %if there are any .txt files
        movefile(['ADHD_',subDir,'*.set'],fullfile(subDir,eegFolder));%move them
    end
    
    %same thing for .fdt files
    numFdtFiles = length(fdtfilesList); %count the .txt files
    if numFdtFiles > 0 %if there are any .txt files
        movefile(['ADHD_',subDir,'*.fdt'],fullfile(subDir,eegFolder));%move them
    end   
    
end