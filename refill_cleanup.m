function refill_cleanup(data)

if data.verbose == 0
    storage_dir=fullfile(data.write_dir_dc,'store');
    mkdir(storage_dir);
    movefile(data.epi_mag_fn,storage_dir);
    data.epi_mag_mc_fn = strrep(data.epi_mag_fn,'.nii','_mc.nii');
    data.epi_mag_ddc_bet_mc_fn = strrep(data.epi_mag_ddc_bet_fn,'.nii','_mc.nii');
    data.epi_mag_sdc_bet_mc_fn = strrep(data.epi_mag_sdc_bet_fn,'.nii','_mc.nii');
    movefile(data.epi_mag_mc_fn,storage_dir);
    movefile(data.epi_mag_sdc_bet_mc_fn,storage_dir);
    movefile(data.epi_mag_ddc_bet_mc_fn,storage_dir);
    if exist(data.write_dir_steps)==7, rmdir(data.write_dir_steps,'s'); end
    if isfield(data,'write_dir_comp')
        if exist(data.write_dir_comp)==7, rmdir(data.write_dir_comp,'s'); end
    end
    delete(fullfile(data.write_dir_dc,'*.nii'))
    movefile(fullfile(storage_dir, '*'),data.write_dir_dc);
    rmdir(storage_dir);
end
