% -------------------------------------------------------------------------
% Add directory and subfolders to path
% -------------------------------------------------------------------------
clc;
filepath = fileparts(mfilename('fullpath'));
run([filepath '/../RPS_init.m']);

cprintf([0,0.6,0], '<strong>------------------------------------------------</strong>\n');
cprintf([0,0.6,0], '<strong>Rock paper scissors project</strong>\n');
cprintf([0,0.6,0], '<strong>Export of PLV results (general script)</strong>\n');
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
srcPath = [srcPath  '07b_mplv/'];

fileList     = dir([srcPath, 'RPS_d*_07b_mplvAlpha_*.mat']);
fileList     = struct2cell(fileList);
fileList     = fileList(1,:);
numOfFiles   = length(fileList);

sessionNum   = zeros(1, numOfFiles);
fileListCopy = fileList;

for dyad=1:1:numOfFiles
  fileListCopy{dyad} = strsplit(fileList{dyad}, '07b_mplvAlpha_');
  fileListCopy{dyad} = fileListCopy{dyad}{end};
  sessionNum(dyad) = sscanf(fileListCopy{dyad}, '%d.mat');
end

sessionNum = unique(sessionNum);
y = sprintf('%d ', sessionNum);

userList = cell(1, length(sessionNum));

for dyad = sessionNum
  match = find(strcmp(fileListCopy, sprintf('%03d.mat', dyad)), 1, 'first');
  filePath = [srcPath, fileList{match}];
  [~, cmdout] = system(['ls -l ' filePath '']);
  attrib = strsplit(cmdout);
  userList{dyad} = attrib{3};
end

selection = false;
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
% Passband selection
% -------------------------------------------------------------------------
fprintf('<strong>Passband selection...</strong>\n');
passband  = {'Alpha', 'Beta', 'Gamma'};                                     % all available passbands
suffix    = {'alpha', 'beta', 'gamma'};

part = listdlg('PromptString',' Select passband...', ...                    % open the dialog window --> the user can select the passband of interest
                'SelectionMode', 'single', ...
                'ListString', passband, ...
                'ListSize', [220, 300] );
              
passband  = passband{part};
suffix    = suffix{part};
fprintf('You have selected the following passband: %s\n\n', passband);

% -------------------------------------------------------------------------
% Dyad selection
% -------------------------------------------------------------------------
fprintf('<strong>Dyad selection...</strong>\n');
fileList     = dir([srcPath 'RPS_d*_07b_mplv' passband '_' sessionStr...
                    '.mat']);
fileList     = struct2cell(fileList);
fileList     = fileList(1,:);                                               % generate list with filenames of all existing dyads
numOfFiles   = length(fileList);

listOfPart = zeros(numOfFiles, 1);

for i = 1:1:numOfFiles
  listOfPart(i) = sscanf(fileList{i}, ['RPS_d%d_07b_mplv' passband ...      % generate a list of all available numbers of dyads
                                        '_' sessionStr '.mat']);
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
fprintf('<strong>Phase selection...</strong>\n');
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

fprintf('You have selected the following phases:\n');
cellfun(@(x) fprintf('%s, ', x), phaseMark, 'UniformOutput', false);        % show the identifiers of the selected phases in the command window
fprintf('\b\b.\n\n');

clear generalDefinitions part filepath

% -------------------------------------------------------------------------
% Cluster specification
% -------------------------------------------------------------------------
fprintf('<strong>Cluster specification...</strong>\n');
selection = false;
while selection == false
  fprintf('Available options:\n');
  fprintf('[1] - Export the cluster average\n')
  fprintf('[2] - Export the values of single connections\n'),
  x = input('Option: ');
  switch x
    case 1
      selection = true;
      mode = 'cluster';
    case 2
      selection = true;
      mode = 'single';
    otherwise
      selection = false;
      cprintf([1,0.5,0], 'Wrong input!\n');
  end
end

load([srcPath fileList{1}]);                                                % load data of first dyad

eval(['data_mplv=' sprintf('data_mplv_%s', suffix) ';']);                   % transfrom passband specific variable name into the common term data_mplv
eval(['clear ' sprintf('data_mplv_%s', suffix)]);

label     = data_mplv.FP.dyad.label;                                        % extract channel names
numOfChan = length(label);

label_x = repmat(label, 1, numOfChan);                                      % prepare a cell array with all possible connections for cluster specification
label_y = repmat(label', numOfChan, 1);
connMatrix = cellfun(@(x,y) [x '_' y], label_x, label_y, ...
                'UniformOutput', false);

if strcmp(mode, 'cluster')
  prompt_string = 'Select cluster members...';
elseif strcmp(mode, 'single')
  prompt_string = 'Select connections of interest...';
end

part = listdlg('PromptString', prompt_string, ...                           % open the dialog window --> the user can select the connections of interest
                'ListString', connMatrix, ...
                'ListSize', [220, 300] );

row = mod(part, numOfChan);
col = ceil(part/numOfChan);

connMatrixBool = false(numOfChan, numOfChan);
for i=1:1:length(row)
  connMatrixBool(row(i), col(i)) = true;
end

connections = connMatrix(connMatrixBool);

fprintf('\nYou have selected the following connections:\n');
cellfun(@(x) fprintf('%s, ', x), connections, 'UniformOutput', false);      % show the identifiers of the selected connections in the command window
fprintf('\b\b.\n\n');
              
clear data_mplv numOfChan connMatrix row col part i label_x label_y ...
      selection x prompt_string

% -------------------------------------------------------------------------
% Identifier specification
% Generate xls file
% -------------------------------------------------------------------------
fprintf('<strong>Identifier specification...</strong>\n');
desPath = [path 'DualEEG_RPS_results/PLV_export/general/' sessionStr ...    % destination path
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
    xlsFile = [desPath 'PLV_general_export_' identifier{1} '_' ...          % build filename
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
clusterSize = length(connections);
phaseMark   = cellfun(@(x) erase(x, ' '), phaseMark, 'UniformOutput', false);
numOfPhases = length(phaseMark);

cell_array      = cell(clusterSize, 3);
cell_array(:,1) = connections;
cell_array{1,2} = passband;
cell_array{1,3} = mode;
Tinfo    = cell2table(cell_array);                                          % create cluster_info table
if strcmp(mode, 'cluster')
  Tinfo.Properties.VariableNames = {'cluster', 'passband', 'mode'};
elseif strcmp(mode, 'single')
  Tinfo.Properties.VariableNames = {'connections', 'passband', 'mode'};
end

if strcmp(mode, 'cluster')
  cell_array      = num2cell(NaN(numOfFiles, numOfTrials + 1));
  cell_array(:,1) = num2cell(dyads);
  Tdata           = cell2table(cell_array);                                 % create data table
  Tdata.Properties.VariableNames = ['dyad' phaseMark];
elseif strcmp(mode, 'single')
  cell_array      = num2cell(NaN(numOfFiles, numOfTrials * clusterSize + 1));
  cell_array(:,1) = num2cell(dyads);
  Tdata           = cell2table(cell_array);                                 % create data table
  phaseMark       = repmat(phaseMark, clusterSize, 1);
  phaseMark       = reshape(phaseMark,1,[]);
  connections     = repmat(connections, 1, numOfPhases);
  connections     = reshape(connections,1,[]);
  headline        = cellfun(@(x,y) [x '_' y], phaseMark, connections, ...
                            'UniformOutput', false);
  Tdata.Properties.VariableNames = ['dyad' headline];
end

clear cell_array passband phaseMark connections headline numOfPhases

% -------------------------------------------------------------------------
% Import plv values into tables
% -------------------------------------------------------------------------
fprintf('<strong>Import of PLV values...</strong>\n\n');
f = waitbar(0,'Please wait...');

for dyad = 1:1:numOfFiles
  load([srcPath fileList{dyad}]);                                           % load data
  eval(['data_mplv=' sprintf('data_mplv_%s', suffix) ';']);                 % transfrom passband specific variable name into the common term data_mplv
  eval(['clear ' sprintf('data_mplv_%s', suffix)]);

  if any(~strcmp(data_mplv.FP.dyad.label, label))
    error(['Error with dyad %d. The channels are not in the correct ' ...
            'order!\n'], dyads(dyad));
  end

  for trl=1:1:numOfTrials
    waitbar(((dyad-1)*numOfTrials + trl)/(numOfFiles * numOfTrials), ...
                  f, 'Please wait...');
    
    if phaseNum(trl) <= 20                                                  % trial from condition FP
      id = phaseNum(trl);
      data = data_mplv.FP;
    elseif (20 < phaseNum(trl)) && (phaseNum(trl) <=40 )                    % trial from condition PD
      id = phaseNum(trl) - 20;
      data = data_mplv.PD;
    elseif (40 < phaseNum(trl)) && (phaseNum(trl) <=60 )                    % trial from condition PS
      id = phaseNum(trl) - 40;
      data = data_mplv.PS;
    elseif phaseNum(trl) > 60                                               % trial from condition C
      id = phaseNum(trl) - 60;
      data = data_mplv.C;
    end
                
    loc_trl = ismember(data.dyad.trialinfo, id);
    if any(loc_trl)
      if strcmp(mode, 'cluster')
        Tdata(dyad, trl + 1) = ...
                   {mean(data.dyad.mPLV{loc_trl}(connMatrixBool))};
      elseif strcmp(mode, 'single')
        start = (trl - 1) * clusterSize + 2;
        stop  = start + clusterSize - 1;
        Tdata(dyad, start:stop) = ...
                   num2cell(data.dyad.mPLV{loc_trl}(connMatrixBool))';
      end
    end
  end

  clear data_mplv data
end

close(f);
clear f dyad numOfFiles srcPath fileList suffix label dyads trl ...
      numOfTrials loc_trl phaseNum connMatrixBool data_mplv clusterSize ...
      start stop mode id

% -------------------------------------------------------------------------
% Export itpc table into spreadsheet
% -------------------------------------------------------------------------
fprintf('<strong>Export of PLV table into a xls spreadsheet...</strong>\n');

writetable(Tinfo, xlsFile, 'Sheet', 'info');
writetable(Tdata, xlsFile, 'Sheet', 'data');

% -------------------------------------------------------------------------
% Clear workspace
% -------------------------------------------------------------------------
clear xlsFile Tdata Tinfo