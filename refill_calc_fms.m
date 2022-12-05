function data=refill_calc_fms(data)

fprintf(' - copying and rescaling magnitude \n');
fprintf(' - copying and rescaling phase \n');

data=refill_copy_rescale(data);

switch data.this_analysis
    case 'ge'
        fprintf('Calculating GE-based static field map \n');
        text_string='GE';
        mag_fn = data.ge_mag_fn;
        phase_fn = data.ge_phase_fn;
        phase_uw_fn = data.ge_pff_uw_fn;
        fm_fn = data.ge_fm_fn;
        fn_quality=data.ge_quality_fn;
        template_tpoe_string = data.ge_template_tpoe_string;
        te_string = data.ge_te_string;
        tpoe_string = data.ge_tpoe_string;
        mask_fn = data.ge_mask_fn;
        switch data.fm_option
            case 'first_echo'
                current_te = data.TEs(1);
            case 'phase_diff'
                current_te = data.ge_te_diff;
        end
        data.tpoes=1;
    case 'epi'
        fprintf('Calculating REFILL, EPI-based dynamic field maps \n');
        text_string='EPI';
        mag_fn = data.epi_mag_fn;
        phase_fn = data.epi_phase_fn;
        phase_uw_fn = data.epi_phase_uw_fn;
        fm_fn = data.epi_fm_fn;
        fn_quality=data.epi_quality_fn;
        current_te = data.epi_te;
        template_tpoe_string = data.epi_template_tpoe_string;
        te_string = data.epi_te_string;
        tpoe_string = data.epi_tpoe_string;
        mask_fn = data.epi_mask_fn;
end

if strcmp(data.this_analysis, 'epi')
    data.m1=load_untouch_nii(data.epi_filename_mag,1);
    data.m1=single(data.m1.img);
    if data.arc==1
        data.readout_gradient=load_untouch_nii(data.epi_filename_phase,1);
        data.readout_gradient=rescale(data.readout_gradient.img,-pi,pi);
    end
    if data.arc==2
        epi_p1=load_untouch_nii(data.epi_filename_phase,1);
        epi_p2=load_untouch_nii(data.refill_filename_phase,1);
        epi_p1=rescale(epi_p1.img,-pi,pi);
        epi_p2=rescale(epi_p2.img,-pi,pi);
        data.readout_gradient=angle(exp(1i*(epi_p2-epi_p1)));
    end
end
data=refill_calc_readout_gradient(data);

fprintf(' - calculating fm from %s\n', text_string);

fprintf('  - unwrapping %s using ROMEO \n', text_string);
clear RD
RD.phase_fn = phase_fn;
RD.unwrapped_phase_fn = phase_uw_fn;
RD.magnitude_fn = mag_fn;
RD.mask_fn = mask_fn;
RD.q='q';
RD.g='g';
RD.te_string = te_string;
RD.tpoe_string = tpoe_string;
if strcmp(data.this_analysis,'epi') && strcmp(data.romeo_type,'i')
    RD.individual_string = 'i';
    if strcmp(data.this_analysis,'epi')
        % needed for refill?   RD.tpoe_string = tpoe_string;
        RD.template_tpoe_string = template_tpoe_string;
    end
end

if exist(phase_uw_fn)~=2
    RD=romeo_unwrap(RD);
    if RD.status~=0
        fprintf('!romeo unwrapping failed with error %s\n', RD.cmdout);
    end
    movefile(fullfile(data.write_dir_steps,'quality.nii'), fn_quality); 
end
p_uw = load_nii(phase_uw_fn);
p_uw = p_uw.img;

% readout correction
switch data.this_analysis
    case 'epi'
        p_uw = p_uw - data.readoutGradient_poc;
        centre_and_save_nii(make_nii(p_uw), data.epi_phase_uw_rc_fn, data.epi_pixdim); 
end

switch data.this_analysis
    case 'ge'
        %   Just using the first echo time. If all the corrections have worked, this is a scaled fm
        switch data.fm_option
            case 'first_echo'
                fm=p_uw(:,:,:,1)/current_te;
                centre_and_save_nii(make_nii(fm),fm_fn, data.ge_pixdim); 
                clear fm;
                %   Do we ever need to use phase difference? If so, ....
            case 'phase_diff'
                pd=p_uw(:,:,:,2)-p_uw(:,:,:,1);
                centre_and_save_nii(make_nii(pd/current_te),fm_fn, data.ge_pixdim); 
                clear pd;
        end
    case 'epi'
        epi_fm=p_uw/current_te;
        centre_and_save_nii(make_nii(epi_fm),fm_fn, data.epi_pixdim); 
        clear p_uw_nii;
end

% Mask and filter the field map(s)
switch data.this_analysis
    case 'ge'
        current_fm_fn = data.ge_fm_fn;
        pixdim=data.ge_pixdim;
        fn_mask=data.ge_mask_fn;
        fn_masked_fm=data.ge_fm_masked_fn;
        data.qthresh=data.qthresh_ge;
    case 'epi'
        current_fm_fn = data.epi_fm_fn;
        pixdim=data.epi_pixdim;
        fn_mask=data.epi_mask_fn;
        fn_masked_fm=data.epi_fm_masked_fn;
        data.qthresh=data.qthresh_epi;
end

switch data.this_analysis
    case 'ge'
        fn_bet_output=strrep(fn_mask,'.nii','_bet.nii');
        cmd_bet=sprintf('bet %s %s -m', mag_fn, fn_bet_output);
        [status,cmdout]=unix(cmd_bet);
        if status~=0, error(cmdout); end
        fn_bet_output_temp=strrep(fn_bet_output,'.nii','_mask.nii');
        [status,msg]=movefile(fn_bet_output_temp, fn_mask);
        delete(fn_bet_output);
        if status~=1, error(msg); end
        cmd_fslmaths=sprintf('fslmaths %s -ero %s', fn_mask, fn_mask);
        [status,cmdout]=unix(cmd_fslmaths);
        if status~=0, error(cmdout); end
        qmask=load_nii(fn_mask,1);
        qmask=qmask.img;
    case 'epi'
        % create a mask by thresholding the romeo quality map
        fprintf('  - generating a mask from the quality \n');
        quality_nii=load_nii(fn_quality);
        qmask=zeros(size(quality_nii.img));
        qmask(quality_nii.img>data.qthresh)=1;
        if data.verbose==1
            centre_and_save_nii(make_nii(qmask), fullfile(data.write_dir_steps,'qmask.nii'), pixdim);
        end
end

% mask the FM with the mask
fprintf('  - masking and smoothing the fms, tp=');
fm_nii=load_nii(current_fm_fn);

if strcmp(data.this_analysis,'ge')
    tpoes=1;
else
    tpoes=data.tpoes;
end
if data.verbose==1
    limits_fml=zeros(size(fm_nii.img));
    limits_fmh=zeros(size(fm_nii.img));
end
for i=1:numel(tpoes)
    if i<numel(tpoes)
        fprintf('%i,', i);
    else
        fprintf('%i\n', i);
    end
    one_tp=fm_nii.img(:,:,:,i);
    one_tp_copy=one_tp;
    if data.verbose==1
        limit_fml=zeros(size(one_tp));
        limit_fmh=zeros(size(one_tp));
    end
    one_tp(one_tp_copy<data.fmthreshl)=NaN;
    one_tp(one_tp_copy>data.fmthreshh)=NaN;
    one_tp(qmask==0)=NaN;
    if data.smoothns~=0
        one_tp=smoothn(one_tp,data.smoothns);
    end
    fm_nii.img(:,:,:,i)=one_tp;
    if data.verbose==1
        limit_fml(one_tp_copy<data.fmthreshl)=1;
        limit_fmh(one_tp_copy>data.fmthreshh)=1;
        limits_fml(:,:,:,i)=limit_fml;
        limits_fmh(:,:,:,i)=limit_fmh;
    end
end
centre_and_save_nii(fm_nii, fn_masked_fm, pixdim); 
if data.verbose > 0
    centre_and_save_nii(make_nii(limits_fml), fullfile(data.write_dir_steps,'excluded_voxels_fm_low.nii'), pixdim);
    centre_and_save_nii(make_nii(limits_fmh), fullfile(data.write_dir_steps,'excluded_voxels_fm_high.nii'), pixdim);
end

switch data.this_analysis
    case 'ge'
        data.ge_fm_to_use_fn=fn_masked_fm;
        fprintf('  * wrote REFILL dynamic FMs %s (which is in radss-1) \n', data.ge_fm_to_use_fn);
    case 'epi'
        data.epi_fm_to_use_fn=fn_masked_fm;
        fprintf('  * wrote REFILL dynamic FMs %s (which is in radss-1) \n', data.epi_fm_to_use_fn);
end

end