function data=refill_copy_rescale(data)

switch data.this_analysis
    case 'ge'
        data.this_filename_mag=data.ge_filename_mag;
        data.this_filename_phase=data.ge_filename_phase;
        data.this_mag_fn=data.ge_mag_fn;
        data.this_phase_fn=data.ge_phase_fn;
        data.this_pixdim=data.ge_pixdim;
        data.tpoes=data.ge_tpoes;
    case 'epi'
        if strcmp(data.aspire,'no')
            data.this_filename_mag=data.epi_filename_mag;
            data.this_filename_phase=data.epi_filename_phase;
            data.this_mag_fn=data.epi_mag_fn;
            data.this_phase_fn=data.epi_phase_fn;
        else
            data.this_filename_mag=data.epi_mag_fn;
            data.this_filename_phase=data.epi_phase_fn;
        end
        data.this_pixdim=data.epi_pixdim;
        data.tpoes=data.epi_tpoes;
end

%   need a copy of the epi magnitude for the sdc (ge)
if strcmp(data.this_analysis,'ge') 
    if strcmp(data.aspire,'no') && ~exist(data.epi_mag_fn)
        mag_epi=load_untouch_nii(data.epi_filename_mag, data.epi_tpoes);
        mag_epi=mag_epi.img; mag_epi=make_nii(mag_epi); % don't ask. don't
        centre_and_save_nii(mag_epi, data.epi_mag_fn, data.this_pixdim);
        if (data.assess==1)    
            refill_assess(mag_epi,data.epi_mag_fn);
        end
    elseif strcmp(data.aspire,'yes') && ~exist(data.epi_mag_copy_fn)
        mag_epi=load_untouch_nii(data.epi_mag_fn, data.epi_tpoes);
        mag_epi=mag_epi.img;
        centre_and_save_nii(make_nii(mag_epi), data.epi_mag_copy_fn, data.this_pixdim);
    end
end

if strcmp(data.this_analysis,'ge') && strcmp(data.aspire,'yes')
    return
end

% mag=load_untouch_nii(data.this_filename_mag, data.tpoes).img;
% phase=load_untouch_nii(data.this_filename_phase, data.tpoes).img;
mag=load_untouch_nii(data.this_filename_mag, data.tpoes);
mag=mag.img;
phase=load_untouch_nii(data.this_filename_phase, data.tpoes);
phase=phase.img;

phase=rescale(phase, -pi, pi);

if strcmp(data.this_analysis,'epi') && strcmp(data.aspire,'yes')
    data.epi_mag_fn=data.epi_mag_copy_fn;
    data.this_mag_fn=data.epi_mag_fn;
    data.epi_phase_fn=data.epi_phase_copy_fn;
    data.this_phase_fn=data.epi_phase_fn;
end

%   for sep-channel, calculate and use the PD
if strcmp(data.this_analysis,'ge') && strcmp(data.aspire,'no') && data.ge_dims(1)==5    
    c_sum=sum(mag(:,:,:,data.echoes_to_use(1),:).*exp(1i*(phase(:,:,:,data.echoes_to_use(2),:)-phase(:,:,:,data.echoes_to_use(1),:))),5);
    phase=angle(c_sum);
    mag=abs(c_sum);
    data.ge_dims(1)=4;
    data.ge_dims(5)=1;
    data.ge_dims(6)=1;
end

centre_and_save_nii(make_nii(mag), data.this_mag_fn, data.this_pixdim); 
%   last echo ge m, for comparison
if ~exist(data.ge_mag_copy_fn)
    if data.verbose > 0, centre_and_save_nii(make_nii(mag(:,:,:,end)), data.ge_mag_copy_fn, data.this_pixdim); end
end
%if strcmp(data.this_analysis,'epi') && (data.assess==1) && (data.verbose > 0)
if strcmp(data.this_analysis,'epi')
    mag_nii=make_nii(mag);
    mag_nii.hdr.dime.pixdim=data.epi_pixdim;
    refill_assess(mag_nii,data.this_mag_fn);
end

centre_and_save_nii(make_nii(phase), data.this_phase_fn, data.this_pixdim); 

