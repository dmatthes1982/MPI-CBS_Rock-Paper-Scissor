% -------------------------------------------------------------------------
% Add directory and subfolders to path
% -------------------------------------------------------------------------
clc;
filepath = fileparts(mfilename('fullpath'));
run([filepath '/../RPS_init.m']);

cprintf([0,0.6,0], '<strong>------------------------------------------------</strong>\n');
cprintf([0,0.6,0], '<strong>Rock paper scissors project</strong>\n');
cprintf([0,0.6,0], '<strong>Export of PSD results (general script)</strong>\n');
cprintf([0,0.6,0], 'Copyright (C) 2017-2018, Daniel Matthes, MPI CBS\n');
cprintf([0,0.6,0], '<strong>------------------------------------------------</strong>\n');

% -------------------------------------------------------------------------
% Path settings
% -------------------------------------------------------------------------
path = '/data/pt_01843/eegData/';                                           % root path to eeg data

fprintf('\nThe default path is: %s\n', path);

selection = false;
while selection == false
  fprintf('\nDo you want to use the default path?\n');
  x = input('Select [y/n]: ','s');
  if strcmp('y', x)
    selection = true;
    newPaths = false;
  elseif strcmp('n', x)
    selection = true;
    newPaths = true;
  else
    selection = false;
  end
end

if newPaths == true
  path = uigetdir(pwd, 'Select folder...');
  path = strcat(path, '/');
end

clear newPaths

% -------------------------------------------------------------------------
% Session selection
% -------------------------------------------------------------------------
fprintf('\n<strong>Session selection...</strong>\n');
srcPath = [path 'DualEEG_RPS_processedData/'];
srcPath = [srcPath  '08b_pwelch/'];

fileList     = dir([srcPath, 'RPS_d*_08b_pwelch_*.mat']);                   % determine all avaible sessions
fileList     = struct2cell(fileList);
fileList     = fileList(1,:);
numOfFiles   = length(fileList);

sessionNum   = zeros(1, numOfFiles);
fileListCopy = fileList;

for dyad=1:1:numOfFiles
  fileListCopy{dyad} = strsplit(fileList{dyad}, '08b_pwelch_');
  fileListCopy{dyad} = fileListCopy{dyad}{end};
  sessionNum(dyad) = sscanf(fileListCopy{dyad}, '%d.mat');
end

sessionNum = unique(sessionNum);                                    
y = sprintf('%d ', sessionNum);

userList = cell(1, length(sessionNum));                                     % determine session owners

for dyad = sessionNum
  match = find(strcmp(fileListCopy, sprintf('%03d.mat', dyad)), 1, 'first');
  filePath = [srcPath, fileList{match}];
  [~, cmdout] = system(['ls -l ' filePath '']);
  attrib = strsplit(cmdout);
  userList{dyad} = attrib{3};
end

selection = false;                                                          % session selection
while selection == false
  fprintf('The following sessions are available: %s\n', y);
  fprintf('The session owners are:\n');
  for dyad = sessionNum
    fprintf('%d - %s\n', dyad, userList{dyad});
  end
  fprintf('\n');
  fprintf('Please select one session:\n');
  fprintf('[num] - Select session\n\n');
  x = input('Session: ');

  if length(x) > 1
    cprintf([1,0.5,0], 'Wrong input, select only one session!\n');
  else
    if ismember(x, sessionNum)
      selection = true;
      sessionStr = sprintf('%03d', x);
    else
      cprintf([1,0.5,0], 'Wrong input, session does not exist!\n');
    end
  end
end

fprintf('\n');

clear sessionNum fileListCopy y userList match filePath cmdout attrib ...
      fileList numOfFiles x selection dyad

% -------------------------------------------------------------------------
% Dyad selection
% -------------------------------------------------------------------------
fprintf('<strong>Dyad selection...</strong>\n');
fileList     = dir([srcPath 'RPS_d*_08b_pwelch_' sessionStr '.mat']);
fileList     = struct2cell(fileList);
fileList     = fileList(1,:);                                               % generate list with filenames of all existing dyads
numOfFiles   = length(fileList);

listOfPart = zeros(numOfFiles, 1);

for i = 1:1:numOfFiles
  listOfPart(i) = sscanf(fileList{i}, ['RPS_d%d_08b_pwelch_' ...            % generate a list of all available numbers of dyads
                                        sessionStr '.mat']);
end

listOfPartStr = cellfun(@(x) sprintf('%d', x), ...                          % prepare a cell array with all possible options for the following list dialog
                        num2cell(listOfPart), 'UniformOutput', false);

part = listdlg('PromptString',' Select dyads...', ...                       % open the dialog window --> the user can select the participants of interest
                'ListString', listOfPartStr, ...
                'ListSize', [220, 300] );

listOfPartBool = ismember(1:1:numOfFiles, part);                            % transform the user's choise into a binary representation for further use

dyads = listOfPartStr(listOfPartBool);                                      % generate a cell vector with identifiers of all selected dyads

fprintf('You have selected the following dyads:\n');
cellfun(@(x) fprintf('%s, ', x), dyads, 'UniformOutput', false);            % show the identifiers of the selected dyads in the command window
fprintf('\b\b.\n\n');

dyads       = listOfPart(listOfPartBool);                                   % generate dyad vector for further use
fileList    = fileList(listOfPartBool);
numOfFiles  = length(fileList);

clear listOfPart listOfPartStr listOfPartBool i

% -------------------------------------------------------------------------
% Phase selection
% -------------------------------------------------------------------------
fprintf('<strong>Conditions selection...</strong>\n');
filepath = fileparts(mfilename('fullpath'));
load(sprintf('%s/../general/RPS_generalDefinitions.mat', filepath), ...     % load general definitions
     'generalDefinitions');

phaseMark = generalDefinitions.phaseMark;                                   % extract phase identifiers
phaseNum  = generalDefinitions.phaseNum;

phaseMark{1,1} = cellfun(@(x) ['FP_' x], phaseMark{1,1}, ...                % modify phase markers, add condition prefix
                         'UniformOutput', false);
phaseMark{2,1} = cellfun(@(x) ['PD_' x], phaseMark{2,1}, ...
                         'UniformOutput', false);
phaseMark{3,1} = cellfun(@(x) ['PS_' x], phaseMark{3,1}, ...
                         'UniformOutput', false);
phaseMark{4,1} = cellfun(@(x) ['C_' x], phaseMark{4,1}, ...
                         'UniformOutput', false);

phaseMark = [phaseMark{1,1} phaseMark{2,1} phaseMark{3,1} phaseMark{4,1}];  

phaseNum{2,1} = phaseNum{2,1} + 20;                                         % modify phase numbers, add condition offset
phaseNum{3,1} = phaseNum{3,1} + 40;
phaseNum{4,1} = phaseNum{4,1} + 60;

phaseNum = [phaseNum{1,1} phaseNum{2,1} phaseNum{3,1} phaseNum{4,1}];

part = listdlg('PromptString',' Select phases...', ...                      % open the dialog window --> the user can select the phases of interest
                'ListString', phaseMark, ...
                'ListSize', [220, 300] );

phaseMark  = phaseMark(part);
phaseNum   = phaseNum(part);

fprintf('You have selected the following conditions:\n');
cellfun(@(x) fprintf('%s, ', x), phaseMark, 'UniformOutput', false);         % show the identifiers of the selected phases in the command window
fprintf('\b\b.\n\n');

clear generalDefinitions part filepath

% -------------------------------------------------------------------------
% Frequency selection
% -------------------------------------------------------------------------
mode = 0;                                                                   % the mode variable shows which frequency and channel mode was selected.

fprintf('<strong>Frequency selection...</strong>\n');
selection = false;
while selection == false
  fprintf('Available options:\n');
  fprintf('[1] - Export the average over the selected frequencies\n');
  fprintf('[2] - Export the a single values for every selected frequency\n');
  x = input('Option: ');
  switch x
    case 1
      selection = true;
      fmode = 'average';
    case 2
      selection = true;
      fmode = 'singleFreq';
      mode  = mode + 1;
    otherwise
      selection = false;
      cprintf([1,0.5,0], 'Wrong input!\n');
  end
end

load([srcPath fileList{1}]);                                                % load data of first dyad

freqNum   = data_pwelch.FP.part1.freq;
freqStr   = cellfun(@(x) sprintf('%.1fHz', x), ...                          % prepare cell array with all possible frequencies
                    num2cell(freqNum), 'UniformOutput', false);

part = listdlg('PromptString',' Select frequencies of interest...', ...     % open the dialog window --> the user can select the frequencies of interest
                'ListString', freqStr, ...
                'ListSize', [220, 300] );

freqNum = freqNum(part);                                                    % keep selected frequencies for further user
freqStr = freqStr(part);

fprintf('\nYou have selected the following frequencies:\n');
cellfun(@(x) fprintf('%s, ', x), freqStr, 'UniformOutput', false);          % show the selected frequencies in the command window
fprintf('\b\b.\n\n');

clear part x selection

% -------------------------------------------------------------------------
% Cluster specification
% -------------------------------------------------------------------------
fprintf('<strong>Cluster specification...</strong>\n');
selection = false;
while selection == false
  fprintf('Available options:\n');
  fprintf('[1] - Export the cluster average\n');
  fprintf('[2] - Export the values of single channels\n');
  x = input('Option: ');
  switch x
    case 1
      selection = true;
      cmode = 'cluster';
    case 2
      selection = true;
      cmode = 'singleChan';
      mode  = mode + 2;
    otherwise
      selection = false;
      cprintf([1,0.5,0], 'Wrong input!\n');
  end
end

labelOrig = data_pwelch.FP.part1.label;                                     % extract channel names

if strcmp(cmode, 'cluster')
  prompt_string = 'Select cluster members...';
elseif strcmp(cmode, 'singleChan')
  prompt_string = 'Select channels of interest...';
end

part = listdlg('PromptString', prompt_string, ...                           % open the dialog window --> the user can select the channels of interest
                'ListString', labelOrig, ...
                'ListSize', [220, 300] );

label = labelOrig(part);

fprintf('\nYou have selected the following channels:\n');
cellfun(@(x) fprintf('%s, ', x), label, 'UniformOutput', false);            % show the selected channels in the command window
fprintf('\b\b.\n\n');
              
clear data_pwelch numOfChan part selection x prompt_string

% -------------------------------------------------------------------------
% Identifier specification
% Generate xls file
% -------------------------------------------------------------------------
fprintf('<strong>Identifier specification...</strong>\n');
desPath = [path 'DualEEG_RPS_results/PSD_export/general/' sessionStr ...    % destination path
          '/'];

if ~exist(desPath, 'dir')                                                   % generate session dir, if not exist
  mkdir(desPath);
end

template_file = [path 'DualEEG_RPS_templates/' ...                          % template file
                  'general/Export_template.xls'];

selection = false;
while selection == false
  identifier = inputdlg(['Specify file identifier (use only letters '...
                         'and/or numbers):'], 'Identifier specification');
  if ~all(isstrprop(identifier{1}, 'alphanum'))                             % check if identifier is valid
    cprintf([1,0.5,0], ['Use only letters and or numbers for the file '...
                        'identifier\n']);
  else
    xlsFile = [desPath 'PSD_general_export_' identifier{1} '_' ...          % build filename
              sessionStr '.xls'];
    if exist(xlsFile, 'file')                                               % check if file already exists
      cprintf([1,0.5,0], 'A file with this identifier exists!');
      selection2 = false;
      while selection2 == false
        fprintf('\nDo you want to overwrite this existing file?\n');        % ask if existing file should be overwritten
        x = input('Select [y/n]: ','s');
        if strcmp('y', x)
          selection2 = true;
          selection = true;
          [~] = copyfile(template_file, xlsFile);                           % copy template to destination
          fprintf('\n');
        elseif strcmp('n', x)
          selection2 = true;
          fprintf('\n');
        else
          cprintf([1,0.5,0], 'Wrong input!\n');
          selection2 = false;
        end
      end
    else
      selection = true;
      [~] = copyfile(template_file, xlsFile);                               % copy template to destination
    end
  end
end

fprintf('Your destination file is:\n');
fprintf('%s\n\n', xlsFile);

clear desPath template_file path identifier selection selection2 x ...
      sessionStr

% -------------------------------------------------------------------------
% Generate table templates
% -------------------------------------------------------------------------
numOfTrials = length(phaseNum);
phaseMark   = cellfun(@(x) erase(x, ' '), phaseMark, 'UniformOutput', false);
numOfChan   = length(label);
numOfFreq   = length(freqNum);
numOfPart   = numOfFiles * 2;
tableLength = max([numOfChan, numOfFreq]);

part_suffix = repmat([1;2],numOfFiles,1);                                   % generate participants identifiers
part_prefix = repmat(dyads',2,1);
part_prefix = reshape(part_prefix,1,[])';
part = cellfun(@(x,y) sprintf('%d_%d',x,y), num2cell(part_prefix), ... 
                num2cell(part_suffix), 'UniformOutput', false);

cell_array      = cell(tableLength, 4);                                     % create info template                                 
cell_array(1:numOfChan,1) = label;
cell_array(1:numOfFreq,2) = freqStr;
cell_array{1,3} = cmode;
cell_array{1,4} = fmode;
Tinfo    = cell2table(cell_array);
if strcmp(cmode, 'cluster')
  Tinfo.Properties.VariableNames = {'cluster', 'frequencies', 'chanMode', 'freqMode'};
elseif strcmp(cmode, 'singleChan')
  Tinfo.Properties.VariableNames = {'channels', 'frequencies', 'chanMode', 'freqMode'};
end

switch mode                                                                 % generate data template
  case 0 % average & cluster                                                                   
    cell_array      = num2cell(NaN(numOfPart, numOfTrials + 1));
    cell_array(:,1) = num2cell(part);
    Tdata           = cell2table(cell_array);
    Tdata.Properties.VariableNames = ['participant' phaseMark];             % generate the headline
  case 1 % singleFreq & cluster
    cell_array      = num2cell(NaN(numOfPart, numOfTrials * numOfFreq + 1));
    cell_array(:,1) = num2cell(part);
    Tdata           = cell2table(cell_array);
    phaseMark       = repmat(phaseMark, numOfFreq, 1);                      % generate the headline
    phaseMark       = reshape(phaseMark,1,[]);
    freqStr         = repmat(freqStr, 1, numOfTrials);
    freqStr         = cellfun(@(x) strrep(x,'.','_'), freqStr, ...
                            'UniformOutput', false);
    headline        = cellfun(@(x,y) [x '_' y], phaseMark, freqStr, ...
                            'UniformOutput', false);
    Tdata.Properties.VariableNames = ['participant' headline];
  case 2 % average & singleChan
    cell_array      = num2cell(NaN(numOfPart, numOfTrials * numOfChan + 1));
    cell_array(:,1) = num2cell(part);
    Tdata           = cell2table(cell_array);
    phaseMark       = repmat(phaseMark, numOfChan, 1);                      % generate the headline
    phaseMark       = reshape(phaseMark,1,[]);
    label           = repmat(label, numOfTrials, 1)';
    headline        = cellfun(@(x,y) [x '_' y], phaseMark, label, ...
                            'UniformOutput', false);
    Tdata.Properties.VariableNames = ['participant' headline];
  case 3 % singelFreq & singleChan
    cell_array      = num2cell(NaN(numOfPart, numOfTrials * numOfChan * numOfFreq + 1));
    cell_array(:,1) = num2cell(part);
    Tdata           = cell2table(cell_array);
    phaseMark       = repmat(phaseMark, numOfChan * numOfFreq, 1);          % generate the headline
    phaseMark       = reshape(phaseMark,1,[]);
    label           = repmat(label', numOfFreq, 1);
    label           = reshape(label,1,[]);
    label           = repmat(label, 1, numOfTrials);
    freqStr         = repmat(freqStr, 1, numOfTrials * numOfChan);
    freqStr         = cellfun(@(x) strrep(x,'.','_'), freqStr, ...
                            'UniformOutput', false);
    headline        = cellfun(@(x,y,z) [x '_' y '_' z], phaseMark, ...
                            label, freqStr, 'UniformOutput', false);
    Tdata.Properties.VariableNames = ['participant' headline];
  otherwise
    error('Something weird happend! The mode variable has an unsupported value.\n'); 
end

clear cell_array passband phaseMark headline freqStr cmode fmode ...
      part_suffix part_prefix part tableLength numOfPart

% -------------------------------------------------------------------------
% Import psd values into tables
% -------------------------------------------------------------------------
fprintf('<strong>Import of PSD values...</strong>\n\n');
f = waitbar(0,'Please wait...');

for dyad = 1:1:numOfFiles
  load([srcPath fileList{dyad}]);                                           % load data
  
  if any(~strcmp(data_pwelch.FP.part1.label, labelOrig))
    error(['Error with dyad %d. The channels are not in the correct ' ...
            'order!\n'], dyads(dyad));
  end

  for trl=1:1:numOfTrials
    waitbar(((dyad-1)*numOfTrials + trl)/(numOfFiles * numOfTrials), ...
                  f, 'Please wait...');
    
    if phaseNum(trl) <= 20                                                  % trial from condition FP
      id = phaseNum(trl);
      data = data_pwelch.FP;
    elseif (20 < phaseNum(trl)) && (phaseNum(trl) <=40 )                    % trial from condition PD
      id = phaseNum(trl) - 20;
      data = data_pwelch.PD;
    elseif (40 < phaseNum(trl)) && (phaseNum(trl) <=60 )                    % trial from condition PS
      id = phaseNum(trl) - 40;
      data = data_pwelch.PS;
    elseif phaseNum(trl) > 60                                               % trial from condition C
      id = phaseNum(trl) - 60;
      data = data_pwelch.C;
    end
    
    loc_trl = ismember(data.part1.trialinfo, id);                           % participant 1
    if any(loc_trl)
      psdPart1 = squeeze(data.part1.powspctrm(loc_trl,:,:));
      loc_freq = ismember(data.part1.freq, freqNum);
      loc_chan = ismember(data.part1.label, label);
      psdPart1 = psdPart1(loc_chan, loc_freq);
      row = 2*dyad - 1;
      
      switch mode
        case 0 % average & cluster
          psdPart1 = reshape(psdPart1, [], 1);
          Tdata(row, trl + 1) = {nanmean(psdPart1)};
        case 1 % singleFreq & cluster
          start = (trl - 1) * numOfFreq + 2;
          stop  = start + numOfFreq - 1;
          Tdata(row ,start:stop) = num2cell(nanmean(psdPart1, 1));
        case 2 % average & singleChan
          start = (trl - 1) * numOfChan + 2;
          stop  = start + numOfChan - 1;
          Tdata(row ,start:stop) = num2cell(transpose(...
                                            nanmean(psdPart1, 2)));
        case 3 % singelFreq & singleChan
          start = (trl - 1) * (numOfChan * numOfFreq) + 2;
          stop  = start + (numOfChan * numOfFreq) - 1;
          psdPart1 = transpose(psdPart1);
          psdPart1 = reshape(psdPart1,[],1);
          psdPart1 = transpose(psdPart1);
          Tdata(row ,start:stop) = num2cell(psdPart1);
      end
    end
    
    loc_trl = ismember(data.part2.trialinfo,id);                            % participant 2
    if any(loc_trl)
      psdPart2 = squeeze(data.part2.powspctrm(loc_trl, :, :));
      loc_freq = ismember(data.part2.freq, freqNum);
      loc_chan = ismember(data.part2.label, label);
      psdPart2 = psdPart2(loc_chan, loc_freq);
      row = 2*dyad;
      
      switch mode
        case 0 % average & cluster
          psdPart2 = reshape(psdPart2, [], 1);
          Tdata(row, trl + 1 ) = {nanmean(psdPart2)};
        case 1 % singleFreq & cluster
          start = (trl - 1) * numOfFreq + 2;
          stop  = start + numOfFreq - 1;
          Tdata(row ,start:stop) = num2cell(nanmean(psdPart2, 1));
        case 2 % average & singleChan
          start = (trl - 1) * numOfChan + 2;
          stop  = start + numOfChan - 1;
          Tdata(row ,start:stop) = num2cell(transpose(...
                                            nanmean(psdPart2, 2)));
        case 3 % singelFreq & singleChan
          start = (trl - 1) * (numOfChan * numOfFreq) + 2;
          stop  = start + (numOfChan * numOfFreq) - 1;
          psdPart2 = transpose(psdPart2);
          psdPart2 = reshape(psdPart2,[],1);
          psdPart2 = transpose(psdPart2);
          Tdata(row ,start:stop) = num2cell(psdPart2);
      end
    end
  end

  clear data_pwelch data
end

close(f);
clear f dyad numOfFiles srcPath fileList labelOrig dyads trl loc_chan ...
      numOfTrials loc_trl phaseNum data_pwelch loc_freq start stop mode ...
      freqNum psdPart1 psdPart2 label row numOfChan numOfFreq mode id

% -------------------------------------------------------------------------
% Export psd table into spreadsheet
% -------------------------------------------------------------------------
fprintf('<strong>Export of PSD table into a xls spreadsheet...</strong>\n');

writetable(Tinfo, xlsFile, 'Sheet', 'info');
writetable(Tdata, xlsFile, 'Sheet', 'data');

% -------------------------------------------------------------------------
% Clear workspace
% -------------------------------------------------------------------------
clear xlsFile Tdata Tinfo
