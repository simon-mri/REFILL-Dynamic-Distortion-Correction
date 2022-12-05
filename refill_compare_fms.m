function data=refill_compare_fms(data)

ge_fm=load_nii(data.ge_fm_demedianed_fn);ge_fm=ge_fm.img;
epi_fm=load_nii(data.epi_fm_demedianed_dc_fn);epi_fm=epi_fm.img;
ge_mask=load_nii(data.ge_mask_fn,1);ge_mask=ge_mask.img;

cmd_bet=sprintf('bet %s %s -f 0.5 -m', data.epi_quality_dc_fn, data.epi_quality_dc_bet_fn);
[status,cmdout]=unix(cmd_bet);
if status~=0, error(cmdout); end
delete(data.epi_quality_dc_bet_fn);
epi_mask=load_nii(data.epi_quality_dc_bet_mask_fn);epi_mask=epi_mask.img;
epi_mask2=load_nii(data.epi_mag_ddc_bet_mask_fn);epi_mask2=epi_mask2.img;

diff=ge_fm-epi_fm;
diff(epi_mask==0)=NaN;
diff(epi_mask2==0)=NaN;

centre_and_save_nii(make_nii(diff),fullfile(data.write_dir_comp, 'diff_fm_ge-epi.nii'),data.ge_pixdim);

diff_ge_minus_epi_hz=(ge_fm-epi_fm) / 2 / pi;
diff_ge_minus_epi_hz(ge_mask~=1)=NaN; % mask is conservative, mask is generous
diff_ge_minus_epi_hz(diff_ge_minus_epi_hz==0)=NaN;
diff_ge_minus_epi_hz(epi_mask~=1)=NaN;
fprintf('Mean difference = %.3f Hz\n', nanmean(vector(diff_ge_minus_epi_hz)));

fig=figure; set(fig,'visible','off');
h=histogram(diff_ge_minus_epi_hz);
hbinwidth=h.BinWidth;
hnumbins=h.NumBins;
hvalues=h.Values;
hbinedges=h.BinEdges;
close(fig);

fp_hist=fopen(fullfile(data.write_dir_comp,'gefm-epifm_hz.dat'),'w');
for j=1:hnumbins
    fprintf(fp_hist,'%f\t%i\n', hbinedges(j), hvalues(j));
end
fclose(fp_hist);

% for reporting percentiles
prctile(vector(diff_ge_minus_epi_hz),10);
prctile(vector(diff_ge_minus_epi_hz),90);

% s1 -5.8,7.4
% s2 -8.3,6.7
% s3 -9.5,7.8
% mean: -7.8+/-1.9Hz->7.5+/-0.5Hz Hz

a=999;
