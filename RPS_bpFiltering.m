function [ data ] = RPS_bpFiltering( cfg, data) 
% RPS_BPFILTERING applies a specific bandpass filter to every channel in
% the RPS_DATASTRUCTURE
%
% Use as
%   [ data ] = RPS_bpFiltering( cfg, data)
%
% where the input data have to be the result from RPS_IMPORTDATASET,
% RPS_PREPROCESSING or RPS_SEGMENTATION 
%
% The configuration options are
%   cfg.bpfreq      = passband range [begin end] (default: [1.9 2.1])
%   cfg.filtorder   = define order of bandpass filter (default: 250)
%
% This function is configured with a fixed filter order, to generate
% comparable filter charakteristics for every operating point.
%
% This function requires the fieldtrip toolbox
%
% See also RPS_IMPORTDATASET, RPS_PREPROCESSING, RPS_SEGMENTATION, 
% RPS_DATASTRUCTURE, FT_PREPROCESSING

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
bpfreq    = ft_getopt(cfg, 'bpfreq', [1.9 2.1]);
order     = ft_getopt(cfg, 'filtorder', 250);

% -------------------------------------------------------------------------
% Filtering settings
% -------------------------------------------------------------------------
cfg                 = [];
cfg.trials          = 'all';                                                % apply bandpass to all trials
cfg.channel         = {'all', '-REF', '-EOGV', '-EOGH'};                    % apply bandpass to every channel except REF, EOGV und EOGH
cfg.bpfilter        = 'yes';
cfg.bpfilttype      = 'fir';                                                % use a simple fir
cfg.bpfreq          = bpfreq;                                               % define bandwith
cfg.feedback        = 'no';                                                 % suppress feedback output
cfg.showcallinfo    = 'no';                                                 % suppress function call output
cfg.bpfiltord       = order;                                                % define filter order

centerFreq = (bpfreq(2) + bpfreq(1))/2;

% -------------------------------------------------------------------------
% Bandpass filtering
% -------------------------------------------------------------------------
data.centerFreq = [];

fprintf('Apply bandpass to participant 1 with a center frequency of %d Hz...\n', ...           
          centerFreq);
data.part1   = ft_preprocessing(cfg, data.part1);        
          
fprintf('Apply bandpass to participant 2 with a center frequency of %d Hz...\n', ...           
          centerFreq);
data.part2   = ft_preprocessing(cfg, data.part2);
  
data.centerFreq = centerFreq;

end
