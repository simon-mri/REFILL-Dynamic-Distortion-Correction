function data=refill_set_defaults(subject)

data.root_dir='/media/uqsrob35/SR_EXT4/';
data.subject=subject;

data.poc_remove_additional_readout_gradient = 'refill'; %'refill'/'from_reg_epi'/'from_file'
data.do_sdc = 1;
data.do_ddc = 1;
data.verbose = 0; % 0 / 1
data.assess = 1; % includes stdev, mean, mosaics, motion-correction
data.fm_option = 'phase_diff'; % 'phase_diff'/'first_echo'
data.tps=999; % time points to analyse; [first:last] or 999(=all)
data.label = '';
data.romeo_type = 'i'; % 'i'/'t' - individual or template ; t is faster but can be wrong if there are very large field changes
data.arc=2; % additional readout correction: (0=none, 1=linear from EPI-FM, 2=REFILL)
% parameters determining fm smoothing and masking
data.smoothns=2;
data.qthresh_epi=0.5;
data.qthresh_ge=0.8;
% sensible limits for realistic field values in the head at 7T - adjust for other field strengths
data.fmthreshl=-600; %rads-1
data.fmthreshh=2000; %rads-1
