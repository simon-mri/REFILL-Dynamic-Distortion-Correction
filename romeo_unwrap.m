%   Calling script for the linux command-line version of the phase unwrapping program ROMEO
%   ROMEO was written by Korbinian Eckstein (korbinian90@gmail.com) in Julia and is available
%   i) in compiled versions https://github.com/korbinian90/ROMEO/releases/tag/v1.4
%   ii) (on publication): an open-source, MR-specified version under https://github.com/korbinian90/MriResearchTools.jl and
%   iii) (on publication): a more general phase unwrapping (e.g. for interferemetry) under https://github.com/korbinian90/ROMEO.jl
%
%   The input and output arguments of romeo_unwrap are the structure RD (Romeo Data), which contains either the data to be unwrapped, or the filename of data to be unwrapped
%   Input, [COMPULSORY]:
%       RD.phase : the 3D or 4D phase image
%     or
%       RD.phase_fn : filename of the 3D or 4D phase image
%   Input, [OPTIONAL]:
%       RD.magnitude : the 3D or 4D magnitude image (if RD.phase was specified)
%       RD.magnitude_fn : filename of the 3D or 4D magnitude image (if RD.phase_fn was specified)
%       RD.unwrapped_phase_fn : sets the output filename and directory. If file names are used and this is not specified, unwrapped_phase_fn is set to {phase_fn}_uw.nii
%       RD.mask_fn : if file names are used and this is not specified, it is set to mask.nii and written in the same directory as RD.unwrapped_phase_fn
%       RD.tpoe_string : corresponds to -e or --unwrap-echoes in ROMEO (the time points or echoes to be unwrapped)
%       RD.individual_string : corresponds to -i, --individual-unwrapping (Unwraps the echoes individually)
%       RD.te_string : corresponds to -t or --echo-times ECHO-TIMES in ROMEO (The relative echo times required for temporal unwrapping (default is 1:n) specified in array or range syntax (eg. [1.5,3.0] or 2:5 or "ones(nr_of_time_points)")
%       RD.template_tpoe_string : --template TEMPLATE   Template time point or echo that is spatially unwrapped and used for temporal unwrapping (type: Int64, default: 2)
%       RD.scan_type : 'epi' sets te_string to "ones(<nr_of_time_points>)" if te_string is not set explicitly
%       RD.unwrap_locally ; % 0=unwrap in output phase directory, 1=unwrap on the local drive specified below (useful if memory mapping used by ROMEO doesn't work e.g. on some network drives). default set below, or pass to override
%       RD.q : 'q'/'Q' : q writes out the combined quality map, Q writes out all quality maps
%       RD.B : 'B': calculates a B0 map from a weighted combination over echoes
%   Output:
%       RD.unwrapped_phase : the 3D or 4D unwrapped phase image (if RD.phase was specified)
%       RD.unwrapped_phase_fn : (if RD.phase_fn was specified)
%       RD.mask : a mask generated from ROMEO's quality maps (if RD.magnitude was specified)
%       RD.mask_fn : a mask generated from ROMEO's quality maps  (if RD.magnitude_fn was specified)
%
%   Default settings for ROMEO are defined with setup_romeo, and can be overwritten by defining the relevant structure members of RD.
%   Simon Robinson 15.5.2020 (simon.robinson@meduniwien.ac.at)

function RD=romeo_unwrap(RD)

%%%%%%% BEGIN USER-DEFINED PARAMETERS %%%%%%%%%%%%%
RD.path_to_binary = '/home/uqsrob35/progs/romeo/mritools_Linux_3.6.3/bin/romeo';
% Below: define a directory on a local disk on which to perform the unwrapping. This is used if
% i) unwrap_locally==1 or
% ii) we are unwrapping an array in memory (RD.phase) rather than data in a file (RD.phase_fn)
unwrap_locally=0;
unwrap_dir='/tmp/romeo'; % safe local place to unwrap
%%%%%%% END USER-DEFINED PARAMETERS %%%%%%%%%%%%%

warning('off', 'MATLAB:MKDIR:DirectoryExists');

if isfield(RD, 'unwrap_locally')
    unwrap_locally=RD.unwrap_locally;
end

if isfield(RD, 'unwrap_dir')
    unwrap_dir=RD.unwrap_dir;
end

%   RD contains data: write to unwrap_dir
if isfield(RD, 'phase')
    using_filenames=0;
    unwrap_locally=1;
    phase=RD.phase; clear RD.phase;
    if isfield(RD, 'pixdim')
        pixdim=RD.pixdim;
    else
        pixdim=ones(8,1)';
    end
    mkdir(unwrap_dir);
    % phase
    phase_lfn=fullfile(unwrap_dir,'phase.nii');
    unwrapped_phase_lfn = fullfile(unwrap_dir,'phase_uw.nii');
    phase_nii=make_nii(phase);
    centre_and_save_nii(make_nii(phase),phase_lfn,pixdim);
    phase_hdr=phase_nii.hdr; clear phase_nii
    if isfield(RD, 'magnitude')
        using_magnitude=1;
        mag=RD.magnitude;
        magnitude_lfn=fullfile(unwrap_dir,'magnitude.nii');
        centre_and_save_nii(make_nii(mag),magnitude_lfn,pixdim);
    else
        using_magnitude=0;
    end
    if ~isfield(RD, 'mask_fn')
        RD.mask_fn=fullfile(unwrap_dir,'mask.nii');
    end
    %   RD contains filenames:
elseif isfield(RD, 'phase_fn')
    using_filenames=1;
    if ~isfield(RD, 'unwrapped_phase_fn')
        RD.unwrapped_phase_fn=strrep(RD.phase_fn,'.nii','_uw.nii');
        fprintf(' - no unwrapped phase filename specified, set to %s\n', RD.unwrapped_phase_fn);
    end
    [results_dir,~,~] = fileparts(RD.unwrapped_phase_fn);
    mkdir(results_dir);
    if unwrap_locally==1
        phase_lfn=fullfile(unwrap_dir,'phase.nii');
        unwrapped_phase_lfn = fullfile(unwrap_dir,'phase_uw.nii');
        copyfile(RD.phase_fn,phase_lfn);
    else
        unwrap_dir=results_dir;
        phase_lfn=RD.phase_fn;
        unwrapped_phase_lfn = RD.unwrapped_phase_fn;
    end
    phase_hdr=load_nii_hdr(phase_lfn);
    if isfield(RD, 'magnitude_fn')
        using_magnitude=1;
        if unwrap_locally==1
            magnitude_lfn=fullfile(unwrap_dir,'magnitude.nii');
            copyfile(RD.magnitude_fn,magnitude_lfn);
        else
            magnitude_lfn=RD.magnitude_fn;
        end
    else
        using_magnitude=0;
    end
    if ~isfield(RD, 'mask_fn')
        RD.mask_fn=fullfile(unwrap_dir,'mask.nii');
    end
else
    error('Neither phase data nor a phase filename was passed');
end

if using_magnitude==1
    mask_lfn = fullfile(unwrap_dir,'mask.nii');
end

dims=phase_hdr.dime.dim(2:5);

if unwrap_locally==1
    fprintf(' - unwrapping on %s\n', unwrap_dir);
    mkdir(unwrap_dir);
end

if using_magnitude==1
    r_mag_string=sprintf('-m %s',magnitude_lfn);
else
    r_mag_string='';
end

r_phase_string=sprintf('-p %s',phase_lfn);

if isfield(RD, 'te_type')
    switch RD.te_type
        case 'epi'
            if ~isfield(RD, 'te_string')
                RD.te_string=sprintf('"ones(%i)"', dims(4));
            end
    end
end

if isfield(RD, 'te_string')
    te_string = sprintf('-t %s ', RD.te_string);
else
    te_string = '';
end

if isfield(RD, 'individual_string') && strcmp(RD.individual_string,'i')
    individual_string = sprintf('-i ');
else
    individual_string = '';
end

if isfield(RD, 'tpoe_string')
    tpoe_string = sprintf('-e %s ', RD.tpoe_string);
else
    tpoe_string = '';
end

if isfield(RD, 'template_tpoe_string')
    template_tpoe_string = sprintf('--template %s ', RD.template_tpoe_string);
else
    template_tpoe_string = '';
end

if isfield(RD, 'q')
    switch RD.q
        case 'q'
            q_string = '-q ';
        case 'Q'
            q_string = '-Q ';
        otherwise
            q_string = '';
    end
else
    q_string = '';
end

if isfield(RD, 'B')
    switch RD.B
        case 'B'
            b_string = '-B ';
        otherwise
            b_string = '';
    end
else
    b_string = '';
end


if isfield(RD, 'k')
    switch RD.k
        case 'nomask'
            k_string = '-k nomask ';
        case 'robustmask'
            k_string = '';
        otherwise
            k_string = sprintf('-k %s',RD.mask_fn);
    end
else
    k_string = '';
end

if isfield(RD, 'g')
    switch RD.g
        case 'g'
            g_string = '-g ';
        otherwise
            g_string = '';
    end
else
    g_string = '';
end

romeo_cmd=sprintf('%s %s %s -o %s %s%s%s%s%s%s%s%s', RD.path_to_binary, r_mag_string, r_phase_string, unwrapped_phase_lfn, te_string, individual_string, tpoe_string, template_tpoe_string, q_string, b_string, k_string, g_string);
    
%   unwrap!
try
    [status,cmdout]=unix(romeo_cmd);
catch
    fprintf('Romeo unwrapping failed. The call was %s', romeo_cmd);
    error('');
end
RD.status=status;
RD.cmdout=cmdout;

if using_filenames==1
    if unwrap_locally==1
        movefile(unwrapped_phase_lfn,RD.unwrapped_phase_fn)
        movefile(fullfile(unwrap_dir,'settings_romeo.txt'),fullfile(results_dir,'settings_romeo.txt'));
        movefile(fullfile(unwrap_dir,'quality*'),results_dir);
    else
        if exist(fullfile(unwrap_dir,'mask.nii'))==2 && ~strcmp(fullfile(unwrap_dir,'mask.nii'),RD.mask_fn)
            movefile(fullfile(unwrap_dir,'mask.nii'),RD.mask_fn);
        end
    end
    fprintf(' - wrote unwrapped phase to %s\n', RD.unwrapped_phase_fn);
else
    p_uw_nii=load_nii(unwrapped_phase_lfn);
    RD.unwrapped_phase=p_uw_nii.img; clear p_uw_nii
    if strcmp(k_string,'robustmask')
        mask_nii=load_nii(mask_lfn);
        RD.mask=mask_nii.img; clear mask_nii;
    end
    switch q_string
        case '-q '
            q_fn=fullfile(unwrap_dir,'quality.nii');
            q_nii=load_nii(q_fn);
            RD.q=q_nii.img;
        case '-Q '
            for i=1:4
                qi_fn=fullfile(unwrap_dir,sprintf('quality_%i.nii',i));
                if exist(qi_fn)==2
                    qi_nii=load_nii(qi_fn);
                    switch i
                        case 1
                            RD.q1=qi_nii.img;
                        case 2
                            RD.q2=qi_nii.img;
                        case 3
                            RD.q3=qi_nii.img;
                        case 4
                            RD.q4=qi_nii.img;
                    end
                    clear q1_nii;
                end
            end
    end
end

%   really need a list of files to delete (masks, quality maps, etc)
if unwrap_locally==1
    if using_magnitude==1
        delete(phase_lfn,magnitude_lfn);
    else
        delete(phase_lfn);
    end
end