% Performs dynamic and static distortion correction of fMRI data as described in "Improved dynamic distortion correction for fMRI using single-echo EPI and a readout-reversed first image (REFILL)"
% Simon Robinson simon.robinson@meduniwien.ac.at 25.11.2022
% v1.1: compatible with R2016b

clearvars
warning off

for subject=[2:3] % refill_select_data
%for subject=[7,11,15] % refill_select_data_SR
%for subject=[11] % refill_select_data_SR

    clear data
    
    data=refill_set_defaults(subject);
    
    data=refill_select_data(data);
    
    data=refill_set_fns(data);
    
    data=refill_get_protocol_pars(data);

    % do refill dynamic dc and/or ge-based static dc
    for i=1:2
        
        if i==1; if data.do_sdc==1, data.this_analysis='ge'; else, continue, end, end
        if i==2; if data.do_ddc==1, data.this_analysis='epi'; else, continue, end, end
                
        data=refill_calc_fms(data);
        
        data=refill_do_dc(data);
        
    end
    
    if data.do_sdc==1 && data.do_ddc==1 
        refill_compare_fms(data);
    end
    
    refill_cleanup(data);
        
end

fprintf('*** Finished ***\n');


