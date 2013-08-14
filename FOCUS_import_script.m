function FOCUS_import_script(varargin)

%for FOCUS

%UPDATE 1/9/13

% This function now displays
% the sampling rate and the subject number to the screen 

%UPDATE 9/24/12

%this is an updated version of import_script, which offers more flexibility
%by allowing the input of varying numbers of segments

%updated on 9/24/12 to include an organization step, where folders are
%created and files are sorted according to extension (probably all .mat in this
%step)

%determine the number of subjects based on the number of subIDs taken by
%the function as arguments

num_sub = length(varargin);

%loop through the subjects
for j = 1:num_sub
    
 %make a variable for the subject's ID number (from argument)   
 subID = varargin{j};
  
 %load corresponding .mat file   
 matlabFile = strcat('ADHD_',num2str(subID),'.fhp.flp.s.cr.ref.mat');

 % The name of the cell array variable in the .mat file follows the
 % format: ADHD_####fhpflpscrref
 arrayName = ['ADHD_',num2str(subID),'fhpflpscrref'];
 
 % Load the array from the matlab file. 
 arrayDataStruct = load(matlabFile, arrayName);
 varName = fieldnames(arrayDataStruct);
 arrayData = arrayDataStruct.(varName{1});
 
 % Calculate the total number of segments
 numSeg = size(arrayData,2);
 
 % Initialize variables to count the number of eyes open and eys closed
 % segments
 numSegOpen = 0;
 numSegClosed = 0;
 
 %initialize new eyes open and eyes closed arrays where the data will be
 %added
 eyesOpenData = [];
 eyesClosedData = [];
 
 for i = 1:numSeg
     
     if arrayData{2,i}(5) == 'o' %if it's an eyesopen segment
         
         eyesOpenData = [eyesOpenData arrayData{1,i}]; %add the data to the existing eyesOpenData array
         
         numSegOpen = numSegOpen + 1; %add one to the counter of eyes open segments
         
     else if arrayData{2,i}(5) == 'c' %if it's an eyesclosed segment
             
            eyesClosedData = [eyesClosedData arrayData{1,i}]; %add the data to the existing eyesClosedData array
            
            numSegClosed = numSegClosed + 1; %add one to the eyes closed segment counter
            
         else %otherwise spit out an error because something weird has happened
             
            error('something didn''t work with the indexing here.\n  arrayData{2,%d}(5) isn''t an ''o'' or a ''c''.', i);
         end
     end        
        
 end
 
 %inform the user how many of each segment type were detected as a check
 disp(['There were ', num2str(numSegClosed), ' eyes closed and ' num2str(numSegOpen), ' eyes open segments analyzed for subject ', num2str(subID)]); 
 
   
 %make file names for the combined data
 eyesOpenFileName = fullfile(['ADHD_', num2str(subID), 'eo']);
 eyesClosedFileName = fullfile(['ADHD_',num2str(subID),'ec']);
   
 %save the files
 save(eyesOpenFileName, 'eyesOpenData');
 save(eyesClosedFileName, 'eyesClosedData');
 FOCUS_organize(varargin{j});
   
end

 
end