function data=refill_select_data(data)

switch data.subject
    case 1 % sub1 in figure 6, sfig2
        data.label = 'Subject 1: Moving Hands';
        data.write_dir = fullfile(data.root_dir,'/refill/results/sub1/fMRI_hands_refill');
        data.read_dir = fullfile(data.root_dir,'refill/data','sub1/nifti');
        if data.do_sdc==1
            data.ge_filename_mag = fullfile(data.read_dir, '4/Image.nii');
            data.ge_filename_phase = fullfile(data.read_dir, '5/Image.nii');
        end
        data.epi_filename_mag = fullfile(data.read_dir, '133/Image.nii');
        data.epi_filename_phase = fullfile(data.read_dir, '134/Image.nii');
        data.refill_filename_mag = fullfile(data.read_dir, '83/Image.nii'); % the epi volume with reversed readout direction
        data.refill_filename_phase = fullfile(data.read_dir, '84/Image.nii'); % the epi volume with reversed readout direction
        data.epi_PE_dir='y'; % asSlice[0].dInPlaneRot was wrong in the retro-reconstructed header - this overrides what is worked out in refill_get_protocol_pars.m
        %data.tps = [1:3]; % for testing; select a few time points for analysis
    case 2 % sub2 in figure 6, sfig3
        data.label = 'Subject 2: Moving Hands';
        data.read_dir = fullfile(data.root_dir,'refill/data','sub2/nifti');
        data.write_dir = fullfile(data.root_dir,'refill/results/sub2/fMRI_hands_refill');
        if data.do_sdc==1
            data.ge_filename_mag = fullfile(data.read_dir, '127/Image.nii');
            data.ge_filename_phase = fullfile(data.read_dir, '128/Image.nii');
        end
        data.epi_filename_mag = fullfile(data.read_dir, '116/Image.nii');
        data.epi_filename_phase = fullfile(data.read_dir, '117/Image.nii');
        data.refill_filename_mag = fullfile(data.read_dir, '74/Image.nii'); 
        data.refill_filename_phase = fullfile(data.read_dir, '75/Image.nii'); 
    case 3 % sub3 in figure 6, sfig4
        data.label = 'Subject 3: Moving Hands';
        data.write_dir = fullfile(data.root_dir,'/refill/results/sub3/fMRI_hands_refill');
        data.read_dir = fullfile(data.root_dir,'refill/data','sub3/nifti');
        if data.do_sdc==1
            data.ge_filename_mag = fullfile(data.read_dir, '3/Image.nii');
            data.ge_filename_phase = fullfile(data.read_dir, '4/Image.nii');
        end
        data.epi_filename_mag = fullfile(data.read_dir, '122/Image.nii');
        data.epi_filename_phase = fullfile(data.read_dir, '123/Image.nii');
        data.refill_filename_mag = fullfile(data.read_dir, '77/Image.nii');
        data.refill_filename_phase = fullfile(data.read_dir, '78/Image.nii');
end

data.epi_header_file=strrep(data.epi_filename_mag,'Image.nii','text_header.txt');
if data.do_sdc==1, data.ge_header_file=strrep(data.ge_filename_mag,'Image.nii','text_header.txt'); end

if strcmp(data.label,''), data.label='(not labelled)'; end
fprintf('Assessing subject/run: %s\n', data.label);
