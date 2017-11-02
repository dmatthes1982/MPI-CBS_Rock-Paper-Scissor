function [ data ] = RPS_importDataset( cfg )
% RPS_IMPORTDATASET imports one specific dataset recorded with a device 
% from brain vision.
%
% Use as
%   [ data ] = RPS_importDataset( cfg )
%
% The configuration options are
%   cfg.path      = source path' (i.e. '/data/pt_01843/eegData/DualEEG_RPS_rawData/')
%   cfg.condition = condition string ('C', 'FP', 'PD', 'PS')
%   cfg.part      = number of participant
%
% You can use relativ path specifications (i.e. '../../MATLAB/data/') or 
% absolute path specifications like in the example. Please be aware that 
% you have to mask space signs of the path names under linux with a 
% backslash char (i.e. '/home/user/test\ folder')
%
% This function requires the fieldtrip toolbox.
%
% See also FT_PREPROCESSING, RPS_DATASTRUCTURE

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
path      = ft_getopt(cfg, 'path', []);
condition = ft_getopt(cfg, 'condition', []);
part      = ft_getopt(cfg, 'part', []);

if isempty(path)
  error('No source path is specified!');
end

if isempty(condition)
  error('No condition is specified!');
end

if isempty(part)
  error('No specific participant is defined!');
end

headerfile = sprintf('%sDualEEG_RPS_%s_%02d.vhdr', path, condition, part);

% -------------------------------------------------------------------------
% General definitions
% -------------------------------------------------------------------------
% definition of all stimuli, which seperate trials. Two values for each 
% phase, the first on is the original one and the second one handles the 
% 'video trigger bug'
eventvalues = { 'S 20','S 148', ...                                         % EyesClose
                'S 10','S 138', ...                                         % Prompt 1,2,3
                'S 11','S 139', ...                                         % Prediction/Desicion (Duration: 1 sec)
                'S 12','S 140', ...                                         % ButtonPress (Duration: 2 sec)
                'S 13','S 141', ...                                         % Action (Duration: 3 sec)
                'S  7','S 135', ...                                         % PanelDownArd (Duration: 2 sec)
                'S 15','S 143', ...                                         % PanelUp (Duration: 4 sec)
                };

samplingRate = 500;
duration = zeros(21,1);                                                    
duration([7, 12])       = 2 * samplingRate;
duration(10)            = 8 * samplingRate;
duration(11)            = 1 * samplingRate;
duration(13)            = 3 * samplingRate;
duration(15)            = 4 * samplingRate;
duration(20)            = 60 * samplingRate;
              
% -------------------------------------------------------------------------
% Data import
% -------------------------------------------------------------------------
% basis configuration for data import
cfg                     = [];
cfg.dataset             = headerfile;
cfg.trialfun            = 'ft_trialfun_general';
cfg.trialdef.eventtype  = 'Stimulus';
cfg.trialdef.prestim    = 0;
cfg.showcallinfo        = 'no';
cfg.feedback            = 'error';
cfg.trialdef.eventvalue = eventvalues;

cfg = ft_definetrial(cfg);                                                  % generate config for segmentation
cfg = rmfield(cfg, {'notification'});                                       % workarround for mergeconfig bug                       

for i = 1:1:size(cfg.trl)                                                   % correct false stimulus numbers
  switch cfg.trl(i,4)
    case 135
      cfg.trl(i,4) = 7;
    case 138
      cfg.trl(i,4) = 10;
    case 139
      cfg.trl(i,4) = 11;
    case 140
      cfg.trl(i,4) = 12;
    case 141
      cfg.trl(i,4) = 13;
    case 143
      cfg.trl(i,4) = 15;
    case 148
      cfg.trl(i,4) = 20;
  end
end

for i = 1:1:length(cfg.trl)                                                 % set specific trial lengths
  cfg.trl(i, 2) = duration(cfg.trl(i, 4)) + cfg.trl(i, 1) - 1;
end

elements = find(ismember(cfg.trl(:,4), 7));                                 % remove duplicates of marker 'S  7', if arduino button is pressed multiple times within one trial
if ~isempty(elements)
  duplicates = [];
  for i=2:1:length(elements)
    if elements(i) == elements(i-1) + 1
      duplicates = [duplicates elements(i)];                                %#ok<AGROW>
    end
  end
  cfg.trl(duplicates, :) = []; 
end

dataTmp = ft_preprocessing(cfg);                                            % import data

data.part1 = dataTmp;                                                       % split dataset into two datasets, one for each participant
data.part1.label = strrep(dataTmp.label(1:32), '_1', '');
for i=1:1:length(dataTmp.trial)
  data.part1.trial{i} = dataTmp.trial{i}(1:32,:);
end

data.part2 = dataTmp;
data.part2.label = strrep(dataTmp.label(33:64), '_2', '');
for i=1:1:length(dataTmp.trial)
  data.part2.trial{i} = dataTmp.trial{i}(33:64,:);
end

end