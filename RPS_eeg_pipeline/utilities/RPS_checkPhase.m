function [ num ] = RPS_checkPhase( phase )
% RPS_CHECKPHASE - This functions checks the defined phase. 
%
% Use as
%   [ num ] = RPS_checkPhase( phase )
%
% If phase is a number the function checks, if this number is equal to 
% one of the default values and return this number in case of confirmity. 
% If phase is a string, the function returns the associated number, if
% the given string is valid. Otherwise the function throws an error.
%
% All available phase strings and numbers are defined in
% RPS_DATASTRUCTURE
%
% See also RPS_DATASTRUCTURE

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Default values
% -------------------------------------------------------------------------
defaultVals = [20, 10, 11, 12, 13, 7, 15];

% -------------------------------------------------------------------------
% Check Condition
% -------------------------------------------------------------------------
if isnumeric(phase)                                                         % if phase is already numeric
  if isempty(find(defaultVals == phase, 1))
    error('%d is not a valid phase', phase);
  else
    num = phase;
  end
else                                                                        % if condition is specified as string
  switch phase
    case 'EyesClosed'
      num = 20;
    case 'Prompt'
      num = 10;
    case 'Prediction'
      num = 11;
    case 'ButtonPress'
      num = 12;
    case 'Action'
      num = 13;
    case 'PanelDownArd'
      num = 7;
    case 'PanelUp'
      num = 15;
    otherwise
      error('%s is not a valid phase', phase);
  end
end
