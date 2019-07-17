function [dat] = read_yokogawa_data_new(filename, hdr, begsample, endsample, chanindx)

% READ_YOKAGAWA_DATA_NEW reads continuous, epoched or averaged MEG data
% that has been generated by the Yokogawa MEG system and software
% and allows that data to be used in combination with FieldTrip.
%
% Use as
%   [dat] = read_yokogawa_data_new(filename, hdr, begsample, endsample, chanindx)
%
% This is a wrapper function around the function
% getYkgwData
%
% See also READ_YOKOGAWA_HEADER_NEW, READ_YOKOGAWA_EVENT

% Copyright (C) 2005, Robert Oostenveld and 2010, Tilmann Sander-Thoemmes
%
% This file is part of FieldTrip, see http://www.fieldtriptoolbox.org
% for the documentation and details.
%
%    FieldTrip is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    FieldTrip is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with FieldTrip. If not, see <http://www.gnu.org/licenses/>.
%
% $Id$

if ~ft_hastoolbox('yokogawa_meg_reader')
    ft_error('cannot determine whether Yokogawa toolbox is present');
end

% hdr = read_yokogawa_header(filename);
hdr = hdr.orig; % use the original Yokogawa header, not the FieldTrip header

% default is to select all channels
if nargin<5
  chanindx = 1:hdr.channel_count;
end

handles = definehandles;

switch hdr.acq_type
  case handles.AcqTypeEvokedAve
    % dat is returned as double
    start_sample  = begsample - 1; % samples start at 0
    sample_length = endsample - begsample + 1;
    epoch_count   = 1;
    start_epoch   = 0;
    dat = getYkgwData(filename, start_sample, sample_length);

  case handles.AcqTypeContinuousRaw
    % dat is returned as double
    start_sample  = begsample - 1; % samples start at 0
    sample_length = endsample - begsample + 1;
    epoch_count   = 1;
    start_epoch   = 0;
    dat = getYkgwData(filename, start_sample, sample_length);

  case handles.AcqTypeEvokedRaw
    % dat is returned as double
    begtrial = ceil(begsample/hdr.sample_count);
    endtrial = ceil(endsample/hdr.sample_count);
    if begtrial<1
      ft_error('cannot read before the begin of the file');
    elseif endtrial>hdr.actual_epoch_count
      ft_error('cannot read beyond the end of the file');
    end
    epoch_count = endtrial-begtrial+1;
    start_epoch = begtrial-1;
    % read all the neccessary trials that contain the desired samples
    dat = getYkgwData(filename, start_epoch, epoch_count);
    if size(dat,2)~=epoch_count*hdr.sample_count
      ft_error('could not read all epochs');
    end
    rawbegsample = begsample - (begtrial-1)*hdr.sample_count;
    rawendsample = endsample - (begtrial-1)*hdr.sample_count;
    sample_length = rawendsample - rawbegsample + 1;
    % select the desired samples from the complete trials
    dat = dat(:,rawbegsample:rawendsample);

  otherwise
    ft_error('unknown data type');
end


if size(dat,1)~=hdr.channel_count
  ft_error('could not read all channels');
elseif size(dat,2)~=(endsample-begsample+1)
  ft_error('could not read all samples');
end

% select only the desired channels
dat = dat(chanindx,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this defines some usefull constants
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles = definehandles
handles.output = [];
handles.sqd_load_flag = false;
handles.mri_load_flag = false;
handles.NullChannel         = 0;
handles.MagnetoMeter        = 1;
handles.AxialGradioMeter    = 2;
handles.PlannerGradioMeter  = 3;
handles.RefferenceChannelMark = hex2dec('0100');
handles.RefferenceMagnetoMeter       = bitor( handles.RefferenceChannelMark, handles.MagnetoMeter );
handles.RefferenceAxialGradioMeter   = bitor( handles.RefferenceChannelMark, handles.AxialGradioMeter );
handles.RefferencePlannerGradioMeter = bitor( handles.RefferenceChannelMark, handles.PlannerGradioMeter );
handles.TriggerChannel      = -1;
handles.EegChannel          = -2;
handles.EcgChannel          = -3;
handles.EtcChannel          = -4;
handles.NonMegChannelNameLength = 32;
handles.DefaultMagnetometerSize       = (4.0/1000.0);       % Square of 4.0mm in length
handles.DefaultAxialGradioMeterSize   = (15.5/1000.0);      % Circle of 15.5mm in diameter
handles.DefaultPlannerGradioMeterSize = (12.0/1000.0);      % Square of 12.0mm in length
handles.AcqTypeContinuousRaw = 1;
handles.AcqTypeEvokedAve     = 2;
handles.AcqTypeEvokedRaw     = 3;
handles.sqd = [];
handles.sqd.selected_start  = [];
handles.sqd.selected_end    = [];
handles.sqd.axialgradiometer_ch_no      = [];
handles.sqd.axialgradiometer_ch_info    = [];
handles.sqd.axialgradiometer_data       = [];
handles.sqd.plannergradiometer_ch_no    = [];
handles.sqd.plannergradiometer_ch_info  = [];
handles.sqd.plannergradiometer_data     = [];
handles.sqd.eegchannel_ch_no   = [];
handles.sqd.eegchannel_data    = [];
handles.sqd.nullchannel_ch_no   = [];
handles.sqd.nullchannel_data    = [];
handles.sqd.selected_time       = [];
handles.sqd.sample_rate         = [];
handles.sqd.sample_count        = [];
handles.sqd.pretrigger_length   = [];
handles.sqd.matching_info   = [];
handles.sqd.source_info     = [];
handles.sqd.mri_info        = [];
handles.mri                 = [];
