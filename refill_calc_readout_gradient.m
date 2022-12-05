function data = refill_calc_readout_gradient(data)

%   Additional Readout Corrections (ARC)

% new numbering
%   0: don't do
%   1: remove any residual linear readout gradient in the first volume of EPI
%   2: remove the linear readout gradient in the difference between a first EPI volume, acquired with one polarity, and a second, acquired with the opposite polarity (a.k.a REFILL)

if strcmp(data.this_analysis, 'ge') || data.arc==0
    data.readoutGradient_poc=0;
    return
end

switch data.epi_PE_dir
    case {'x','x-'}
        current_read_dir='col';
    case {'y','y-'}
        current_read_dir='row';
end
switch data.arc
    case 1
        gradient_rescale_factor=1;
        shift = 1 ;
    case 2
        % we passed it the difference between the first and second volumes, which contains twice the gradient
        gradient_rescale_factor=2;
        shift = 1 ;
end

if data.verbose > 0, centre_and_save_nii(make_nii(data.readout_gradient),fullfile(data.write_dir_steps,'basis_for_gradient_calc.nii'), data.epi_pixdim); end

sizeArr = size(data.readout_gradient);

switch current_read_dir
    case 'row'
        diffMap = data.m1((1+shift):end,:,:).*exp(1i*(data.readout_gradient((1+shift):end,:,:) - data.readout_gradient(1:(end-shift),:,:)));
    case 'col'
        diffMap = data.m1(:,(1+shift):end,:).*exp(1i*(data.readout_gradient(:,(1+shift):end,:) - data.readout_gradient(:,1:(end-shift),:,:)));
end

diffMap(isnan(diffMap))=0;
diff = sum(diffMap(:));

gradient = angle(diff) / gradient_rescale_factor / shift; %!scalar!
fprintf(' - there is a linear gradient in the readout direction of %2.6f Hz/voxel - removing \n', gradient/(2*pi));

rMin = -data.epi_readout_dim/2;
rValues = rMin:(rMin + data.epi_readout_dim - 1);

repSizes = size(data.m1); 
switch current_read_dir
    case 'row'
        repSizes(1) = 1;
    case 'column'
        repSizes(2) = 1;
end

readoutGradient = repmat(rValues, repSizes) * gradient;
readoutGradient  = reshape(readoutGradient, sizeArr);

data.readoutGradient_poc = readoutGradient;

a=0;



