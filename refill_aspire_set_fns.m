function data=refill_aspire_set_fns(data)

data.epi_mag_fn=fullfile(data.write_dir_dc,'epi_m.nii');
data.epi_phase_fn=fullfile(data.write_dir_steps, 'epi_p.nii');

data.epi_mag_sdc_fn=fullfile(data.write_dir_dc, 'epi_m_sdc.nii');
data.epi_mag_sdc_bet_fn=fullfile(data.write_dir_dc, 'epi_m_sdc_bet.nii');
data.epi_mag_ddc_fn=fullfile(data.write_dir_dc, 'epi_m_ddc.nii');
data.epi_mag_ddc_bet_fn=fullfile(data.write_dir_dc, 'epi_m_ddc_bet.nii');
data.epi_mag_ddc_bet_mask_fn=fullfile(data.write_dir_dc, 'epi_m_ddc_bet_mask.nii');
data.epi_mask_fn=fullfile(data.write_dir_steps,'epi_mask.nii');
data.epi_quality_fn=fullfile(data.write_dir_steps, 'epi_quality.nii');
data.epi_quality_dc_fn=fullfile(data.write_dir_steps, 'epi_quality_dc.nii');
data.epi_quality_dc_bet_fn=fullfile(data.write_dir_steps, 'epi_quality_dc_bet.nii');
data.epi_quality_dc_bet_mask_fn=fullfile(data.write_dir_steps, 'epi_quality_dc_bet_mask.nii');
data.epi_phase_uw_fn=fullfile(data.write_dir_steps,'epi_phase_uw.nii');
data.epi_phase_uw_rc_fn=fullfile(data.write_dir_steps,'epi_phase_uw_rc.nii');
data.epi_fm_fn=fullfile(data.write_dir_steps,'epi_fm.nii');
data.epi_fm_dc_fn=fullfile(data.write_dir_steps,'epi_fm_dc.nii');
data.epi_fm_demedianed_fn=fullfile(data.write_dir_steps,'epi_fm-median.nii');
data.epi_fm_demedianed_dc_fn=fullfile(data.write_dir_steps,'epi_fm-median_dc.nii');
data.epi_fm_masked_demedianed_fn=fullfile(data.write_dir_steps,'epi_fm_masked-median.nii');
data.epi_fm_masked_demedianed_dc_fn=fullfile(data.write_dir_steps,'epi_fm_masked-median_dc.nii');
data.epi_fm_masked_fn=fullfile(data.write_dir_steps,'epi_fm_masked.nii');

data.ge_mag_copy_fn=fullfile(data.write_dir_dc,'ge_m.nii');
data.ge_phase_nonan_fn=fullfile(data.write_dir_steps,'ge_p.nii');
data.ge_phase_uw_fn=fullfile(data.write_dir_steps,'ge_p_uw.nii');
data.ge_quality_fn=fullfile(data.write_dir_steps, 'ge_quality.nii');
if data.do_sdc == 1
    data.ge_fm_fn=fullfile(data.write_dir_comp,'ge_fm.nii');
    data.ge_fm_demedianed_fn=fullfile(data.write_dir_steps,'ge_fm-median.nii');
    data.ge_fm_pc_fn=fullfile(data.write_dir_comp,'ge_fm_pc.nii');
    data.ge_fm_fw_fn=fullfile(data.write_dir_comp,'ge_fw_fm.nii');
    data.ge_fm_masked_fn=fullfile(data.write_dir_comp,'ge_fm_masked.nii');
    data.ge_p_at_epi_te_fn=fullfile(data.write_dir_comp, 'ge_p_at_epi_te.nii');
end

data.ge_mask_fn=fullfile(data.write_dir_steps,'ge_mask.nii');
data.ge_bet_mask_fn=fullfile(data.write_dir_steps, 'ge_bet_mask.nii');

% pff = phase for fieldmap
switch data.fm_option
    case 'first_echo'
        data.ge_pff_uw_fn=fullfile(data.write_dir_steps,'ge_p1_uw.nii');
        data.ge_pff_fn=fullfile(data.write_dir_steps,'ge_p1.nii');
    case 'phase_diff'
        data.ge_pff_uw_fn=fullfile(data.write_dir_steps,'ge_pd_uw.nii');
        data.ge_pff_fn=fullfile(data.write_dir_steps,'ge_pd.nii');
end
data.diff_fm_fn=fullfile(data.write_dir_steps,'diff_fm_ge-epi.nii');
%end

if data.do_sdc == 1
    data.ge_mag_fn=fullfile(data.write_dir_dc,'ge_m.nii');
    data.ge_phase_fn=fullfile(data.write_dir_steps, 'ge_p.nii');
    data.ge_mag_dc_fn=fullfile(data.write_dir_steps, 'ge_m_dc.nii');
    data.ge_phase_fn=fullfile(data.write_dir_steps,'ge_p.nii');
    data.ge_mask_fn=fullfile(data.write_dir_steps,'ge_mask.nii');
    data.ge_quality_fn=fullfile(data.write_dir_steps, 'ge_quality.nii');
    
    data.ge_phase_uw_fn=fullfile(data.write_dir_steps,'ge_p_uw.nii');
    data.ge_fm_fn=fullfile(data.write_dir_steps,'ge_fm.nii');
    data.ge_fm_demedianed_fn=fullfile(data.write_dir_steps,'ge_fm-median.nii');
    data.ge_fm_pc_fn=fullfile(data.write_dir_steps,'ge_fm_pc.nii');
    data.ge_fm_fw_fn=fullfile(data.write_dir_steps,'ge_fw_fm.nii');
    data.ge_fm_masked_fn=fullfile(data.write_dir_steps,'ge_fm_masked.nii');
    data.ge_fm_masked_demedianed_fn=fullfile(data.write_dir_steps,'ge_fm_masked-median.nii');
    data.ge_fm_masked_dc_fn=fullfile(data.write_dir_steps,'ge_fm_masked-median_dc.nii');
    data.ge_p_at_epi_te_fn=fullfile(data.write_dir_steps, 'ge_p_at_epi_te.nii');
    
    data.ge_mask_fn=fullfile(data.write_dir_steps,'ge_mask.nii');
    data.ge_bet_mask_fn=fullfile(data.write_dir_steps, 'ge_bet_mask.nii');
    
    % pff = phase for fieldmap
    switch data.fm_option
        case 'first_echo'
            data.ge_pff_uw_fn=fullfile(data.write_dir_steps,'ge_p1_uw.nii');
        case 'phase_diff'
            data.ge_pff_uw_fn=fullfile(data.write_dir_steps,'ge_pd_uw.nii');
    end
    data.diff_fm_fn=fullfile(data.write_dir_steps,'diff_fm_ge-epi.nii');
end

if strcmp(data.aspire,'yes')
    %GE
    data.ge_mag_fn=fullfile(data.aspire_results_dir, 'combined_mag.nii');
    data.ge_phase_fn=fullfile(data.aspire_results_dir, 'combined_phase.nii');
    data.ge_mag_all_fn=fullfile(data.aspire_steps_dir, 'm.nii');
    data.ge_phase_all_fn=fullfile(data.aspire_steps_dir, 'p.nii');
    data.ge_po_fn=fullfile(data.aspire_steps_dir, 'po.nii');
    if data.bipolar==1
        data.ge_po_odd_fn=fullfile(data.aspire_steps_dir, 'po_odd.nii');
        data.ge_po_even_fn=fullfile(data.aspire_steps_dir, 'po_even.nii');
    end
    temp=strrep(data.ge_filename_mag,'reform/','');
    data.ge_header_file=strrep(temp,'Image.nii','text_header.txt');
    copyfile(data.ge_header_file, fullfile(data.aspire_steps_dir, 'text_header.txt'));
    
    %POC
    if data.correct_other_data == 1
        data.epi_mag_fn=fullfile(data.poc_results_dir, 'combined_mag.nii');
        data.epi_phase_fn=fullfile(data.poc_results_dir, 'combined_phase.nii');
        data.epi_mag_all_fn=fullfile(data.poc_steps_dir, 'm.nii');
        data.epi_phase_all_fn=fullfile(data.poc_steps_dir, 'p.nii');
        data.epi_mag_copy_fn=fullfile(data.write_dir_dc,'epi_m.nii');
        data.epi_phase_copy_fn=fullfile(data.write_dir_steps,'epi_p.nii');
        temp=strrep(data.epi_filename_mag,'reform/','');
        data.epi_header_file=strrep(temp,'Image.nii','text_header.txt');
    end
end

