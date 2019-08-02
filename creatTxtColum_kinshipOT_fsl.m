%% Scirpted by Haiyan Wu for extracting onsetTimes for stimuli with four different conditions in oxytocin fMRI experiment e.g., sc=1; oc=2; sa=3; oa=4 
%  2016-10-25 
clc,clear all, close all;
outputdir = []; 
%% import the CSV file that was created by exporting merged eprime edat-files (using E-DataAid)
% The name of the comma-separated values file
% ??? Make sure this contains the input filename (incl path)
% csv or txt files 
csvfile = '101.csv'; 
%%
% The number of header lines in the csv-file. This would be 1 if the file was 
% exported including columns names, or zero otherwise.
% ??? set this to the number of header lines that should be skipped
nHeaderLines = 0; 

% define column parsing format: %d stands for a decimal value, %s for text (doc textscan)
csvformat = '%d %s %d %f %d %d'; 

fid = fopen(csvfile,'rt');
if fid~=-1
    T = textscan(fid, [csvformat '%*[^\n]'], 'Delimiter', ',', 'HeaderLines', nHeaderLines );
else
    error('Cannot open %s\n',csvfile);
end
fclose(fid);
%% if the exported data are txt files
% [Subject,face,ACC, Onset,condition_id, run]=textread('observegambling.txt','%n %n %n %n %n','delimiter',',');
% 
%% define the column numbers 
% 1-subjid;2-face,3-acc,4-onset,5-condition number(1-2,self,3-4partner,5-6opposite),6-run nunmber/session
% Tip: or we can also export the required columns when using E-DataAid (and use E-Merge first to collect all info into one database)
Gam_SUBJECT = 1; % first column is subject number
Gam_Person  = 2; % second is person,txt
Gam_outcome  = 3; %  -5 or +5 outcomes in gambling
Gam_STIM_ONSET = 4; % I have done the subtraction in the Eprime procedure, so the onset times are by seconds now
Gam_STIM_CONDITION = 5; % condition number(sc=1; oc=2; sa=3; oa=4)
Gam_SESSION        = 6; % session number
%% predefine condition names explicitly.
% ??? predefine condition names that correspond to the (sorted) condition numbers (defined below)
% In this simplified case we assume that we have two conditions (with two different pictures per condition)
predef_names={}; 
predef_names{end+1} = '1';
predef_names{end+1} = '2';
predef_names{end+1} = '3';
predef_names{end+1} = '4';
%% copy vectors to helper variables (for scripts readability)
% ??? each relevant (numerical) column is copied to a separate vector
subjects        = T{Gam_SUBJECT};
sessions        = T{Gam_SESSION};
outcome = T{Gam_outcome};
stim_onsets     = T{Gam_STIM_ONSET};
conditions = T{Gam_STIM_CONDITION}; % a cell if it contains text
%% get unique sorted subject, session and condition numbers (i.e. without duplicates)
subjectsU=unique(subjects);
sessionsU=unique(sessions);
conditionsU=unique(conditions);
%% get numbers and display them
nSubjects = length(subjectsU);
nSessions = length(sessionsU);
nConditions = length(conditionsU);
fprintf('Number of subjects:   %d\n',nSubjects);
fprintf('Number of sessions:   %d\n',nSessions);
fprintf('Number of Conditions: %d\n',nConditions);
%% loop through subjects
for iSubject=1:nSubjects
    subject=subjectsU(iSubject); % pick the next subject from the list
	
	%% loop through sessions (for each subject)
    for iSession =1:nSessions
        session=sessionsU(iSession); % pick the next session from the list

        fprintf('\nGettings events for subject=%d, session= %d\n',subject,session);
        
        %% initialise SPM variables
        onsets     = cell(1,nConditions);
        % durations  = cell(1,nConditions);
        names      = cell(1,nConditions);
            
        %% loop through conditions
        for iCondition =1:nConditions
            condition=conditionsU(iCondition);
        
            %% fill the 3 SPM variables
            % start with the condition name
            if iCondition<=length(predef_names)
                names{iCondition} = predef_names{iCondition};  % copy the predefined name for this condition
            else
                names{iCondition} = sprintf('Condition %d',iCondition); % just use a number when nothing was predefined
            end
            % ??? enter an expression that selects the rows for this condition
            I = find(subjects==subject & sessions==session & conditions==condition & stim_onsets>0); 
            onsets{iCondition}    = double(stim_onsets(I)); 
            % ??? Use stimulus durations or simply enter zero for events with zero duration with 0*onsets{iCondition}
           % durations{iCondition} = zeros(10,1); 10trials, dur=0             
            fprintf('%d events for %s\n', length(I), names{iCondition});
        end
        
        %% save multiple conditions file per subject per session
        outfile1 = sprintf('%d_%d_1.txt',subject,session);  % tip: use something like %05d to print several leading zero's
        outfile2 = sprintf('%d_%d_2.txt',subject,session);
         outfile3 = sprintf('%d_%d_3.txt',subject,session);
         outfile4 = sprintf('%d_%d_4.txt',subject,session);
        
        times=cell2mat(onsets); %transform cell to matrix for onsets of 4 conditions
       % save(outfile, 'times');
        m=zeros(15,3);
        m(:,2)=1.5;
        m(:,3)=1;
        n=m;
        x=m;
       y=m;
        m(:,1)=times(:,1);
        n(:,1)=times(:,2);
        x(:,1)=times(:,3);
        y(:,1)=times(:,4);
              
        save (outfile1,'-ascii', 'm' );
        save (outfile2,'-ascii', 'n' );
        save (outfile3,'-ascii', 'x' );
        save (outfile4,'-ascii', 'y' );
%         fprintf('saved %s\n',outfile);
    end
end