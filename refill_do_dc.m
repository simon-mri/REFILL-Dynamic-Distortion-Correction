function data=refill_do_dc(data)

switch data.this_analysis
    case 'ge'
        if strcmp(data.aspire,'yes')
            this_epi_fn=data.epi_mag_copy_fn;
        else
            this_epi_fn=data.epi_mag_fn;
        end
        unwarp_command = sprintf('fugue -i %s --loadfmap=%s --unwarpdir=%s --dwell=%f -u %s -v', this_epi_fn, data.ge_fm_to_use_fn, data.epi_PE_dir, data.echo_spacing_to_one_over_rbw_factor*data.epi_eES,  data.epi_mag_sdc_fn);
        %        unwarp_command = sprintf('fugue -i %s --loadfmap=%s --unwarpdir=%s --dwell=%f -u %s -v', data.epi_mag_fn, data.ge_fm_masked_fn, data.epi_PE_dir, data.echo_spacing_to_one_over_rbw_factor*data.epi_eES,  data.epi_mag_sdc_fn);
        % fugue -i mag_tp1.nii --loadfmap=fm_tp1_prelude_masked.nii --unwarpdir=y- --dwell=0.00034554 --nokspace -w mag_tp1_prelude.nii
        [status,cmdout]=unix(unwarp_command);
        if status~=0, error(cmdout); end
        fprintf('  - unwarping the epi; wrote %s \n', data.epi_mag_sdc_fn);
        
        fprintf('  - performing BET on the unwarped images \n');
        cmd_bet=sprintf('bet %s %s -F -m', data.epi_mag_sdc_fn, data.epi_mag_sdc_bet_fn);
        [status,cmdout]=unix(cmd_bet);
        if status~=0, error(cmdout); end
        
        if data.assess==1
            epi_m_sdc_nii=load_nii(data.epi_mag_sdc_bet_fn);
            refill_assess(epi_m_sdc_nii,data.epi_mag_sdc_bet_fn);
        end
    case 'epi'
        % Convert the FM to a VSM and distortion-correct the images
        fprintf('  - converting the fm to a vsm \n');
        current_fm_nii=load_nii(data.epi_fm_to_use_fn);
        current_fm_nii.img(isnan(current_fm_nii.img))=0;
        vsm = data.echo_spacing_to_one_over_rbw_factor*current_fm_nii.img*data.epi_PE_dim/(2*pi*data.epi_rbw*data.epi_acceleration);
        if strcmp(data.epi_PE_dir,'y')
            vsm=-vsm;
        end
        if data.verbose > 0, centre_and_save_nii(make_nii(vsm), fullfile(data.write_dir_steps,'vsm_prelim.nii'),data.epi_pixdim); end
        
        %   unwarp the EPI FM for a preliminary comparison with the FM (for now, just to remove the offset in each)
        fprintf('  - unwarping the refill fieldmaps\n');
        

        epi_fm_uw = aspire_unwarp(vsm, current_fm_nii.img);
        
        % Compare the FM and EPI fieldmaps
               
        epi_fm_nii = make_nii(epi_fm_uw);
        mask=load_nii(data.epi_mask_fn);
        mask=mask.img;

        % zero each, individually, based on the in-mask median
        % GE
        if isfield(data,'ge_fm_to_use_fn')==1
            %   1: the FM of interest
            ge_fm = load_nii(data.ge_fm_masked_fn);
            ge_fm = ge_fm.img;
            mask=load_nii(data.ge_mask_fn,1);             
            mask=mask.img;             
            ge_fm(mask~=1)=NaN;
            median_ge_fm = median(vector(ge_fm),'omitnan');
            fprintf('Median in centre of GE-FM=%4.2f radss-1; removing ...\n', median_ge_fm);
            ge_fm = ge_fm - median_ge_fm;
            if data.verbose > 0, centre_and_save_nii(make_nii(ge_fm), data.ge_fm_masked_demedianed_fn, data.ge_pixdim); end
            %   2: an unfiltered FM for comparison            
            ge_fm = load_nii(data.ge_fm_fn); ge_fm = ge_fm.img;
            ge_fm = ge_fm - median_ge_fm;
            centre_and_save_nii(make_nii(ge_fm), data.ge_fm_demedianed_fn, data.ge_pixdim);
        end
        
        % EPI
        %   1: the FM of interest
        epi_fm=epi_fm_nii.img;
        epi_fm(mask~=1)=NaN;
        % centre_and_save_nii(make_nii(epi_fm), fullfile(data.write_dir_steps, 'epi_fm-nan-masked.nii'),data.ge_pixdim);
        median_epi_fm = median(vector(epi_fm),'omitnan');
        fprintf('Median in centre of EPI-FM=%4.2f radss-1; removing ...\n', median_epi_fm);
        epi_fm_nii.img = epi_fm_nii.img - median_epi_fm;
        if data.verbose > 0, centre_and_save_nii(epi_fm_nii, data.epi_fm_masked_demedianed_fn, data.epi_pixdim); end
        %   2: an unfiltered FM for comparison        
        epi_fm=load_nii(data.epi_fm_fn);
        epi_fm=epi_fm.img;
        epi_fm = epi_fm - median_epi_fm;
        if data.verbose > 0, centre_and_save_nii(make_nii(epi_fm), data.epi_fm_demedianed_fn, data.epi_pixdim); end
        
        %   for distortion correction, need to subtract the same amount from the EPI-FM in the distorted space and recalculate the VSM
        current_fm_nii.img=current_fm_nii.img-median_epi_fm;
        current_fm_nii.img(isnan(current_fm_nii.img))=0;
        vsm = data.echo_spacing_to_one_over_rbw_factor*current_fm_nii.img*data.epi_PE_dim/(2*pi*data.epi_rbw*data.epi_acceleration) ;
        if strcmp(data.epi_PE_dir,'y')
            vsm=-vsm;
        end
        if data.verbose > 0, centre_and_save_nii(make_nii(vsm), fullfile(data.write_dir_steps,'vsm.nii'),data.epi_pixdim); end
        if strcmp(data.this_analysis,'epi') && (data.assess==1) && (data.verbose>0)
            refill_assess(make_nii(vsm),fullfile(data.write_dir_steps,'vsm.nii'));
        end
        
        %   Do the distortion correction
        %   EPI magnitude
%        mag_comb_nii=load_nii(data.epi_mag_fn,data.epi_tpoes);
        mag_comb_nii=load_nii(data.epi_mag_fn);
        fprintf('  - unwarping the epi \n');
        mag_uw_nii = mag_comb_nii;
        mag_uw_nii.img = aspire_unwarp(vsm, mag_uw_nii.img);
        
        centre_and_save_nii(mag_uw_nii, data.epi_mag_ddc_fn,data.epi_pixdim); 
        
        fprintf('  - performing BET on the unwarped images \n');
        cmd_bet=sprintf('bet %s %s -F -m', data.epi_mag_ddc_fn, data.epi_mag_ddc_bet_fn);
        [status,cmdout]=unix(cmd_bet);
        if status~=0, error(cmdout); end
        
        if strcmp(data.this_analysis,'epi') && (data.assess==1)
            mag_uw_nii=load_nii(data.epi_mag_ddc_bet_fn);
            refill_assess(mag_uw_nii,data.epi_mag_ddc_bet_fn);
        end
        
        %   EPI FM to use for DC (with what should now be a correct vsm)
        fprintf('  - unwarping the vsm \n');
        epi_fm_uw = aspire_unwarp(vsm, current_fm_nii.img);
        if data.verbose > 0, centre_and_save_nii(make_nii(epi_fm_uw), data.epi_fm_masked_demedianed_dc_fn,data.epi_pixdim); end
        
        %   EPI FM, not masked or filtered, to compare with GE
        epi_fm_uw = aspire_unwarp(vsm, epi_fm);
        centre_and_save_nii(make_nii(epi_fm_uw), data.epi_fm_demedianed_dc_fn,data.epi_pixdim);
        
        %   EPI quality map, so we have that in the undistorted space for comparison
        fprintf('  - unwarping the epi quality map \n');
        epi_quality=load_nii(data.epi_quality_fn);
        epi_quality=epi_quality.img;
        epi_quality_uw = aspire_unwarp(vsm, epi_quality);
        centre_and_save_nii(make_nii(epi_quality_uw), data.epi_quality_dc_fn,data.epi_pixdim);
end