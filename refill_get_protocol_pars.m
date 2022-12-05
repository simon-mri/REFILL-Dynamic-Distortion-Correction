function data=refill_get_protocol_pars(data)

%EPI,dim
epi_hdr = load_nii_hdr(data.epi_filename_mag);
data.epi_dims = epi_hdr.dime.dim;

%EPI,pixdim
data.epi_pixdim = epi_hdr.dime.pixdim;

%EPI,phase-encode direction
if ~isfield(data, 'epi_PE_dir') % can be hard-coded in refill_select_data (in case the header parameters are wrong after retro-recon)
    data.epi_PE_dir = search_all_header_func(data.epi_header_file, 'InPlanePhaseEncodingDirection');
    switch data.epi_PE_dir
        case 'COL'
            APPA = round(str2num(search_all_header_func(data.epi_header_file, 'asSlice[0].dInPlaneRot'))/pi);
            switch APPA
                case 1
                    data.epi_PE_dir = 'y';
                otherwise
                    data.epi_PE_dir = 'y-';
            end
        case 'ROW' % could do with a bit more checking
            LRRL = round((2*str2num(search_all_header_func(data.epi_header_file, 'asSlice[0].dInPlaneRot')))/pi);
            switch LRRL
                case '1'
                    data.epi_PE_dir = 'x';
                otherwise
                    data.epi_PE_dir = 'x-';
            end
        otherwise
            error('phase-encoding direction couldn''t be determined');
    end
end

if contains(data.epi_PE_dir,'-')
    data.epi_PE_opposite_dir=strrep(data.epi_PE_dir,'-','');
else
    data.epi_PE_opposite_dir=[data.epi_PE_dir '-'];
end

% assuming axial...
switch data.epi_PE_dir
    case {'y','y-'}
        data.epi_PE_dim = data.epi_dims(3);
        data.epi_readout_dim = data.epi_dims(2);
    case {'x','x-'}
        data.epi_PE_dim = data.epi_dims(2);
        data.epi_readout_dim = data.epi_dims(3);
end

%!!!!!! This magic number is a very close estimate for FoV~=210mm and rbw~=1500 but need to write the echo spacing into the dicom text part and take exact value from that; see example in a_ep_CommonUI.cpp; dVal = pThis->sequence().getSEQ_BUFF()->getSeqExpo().getEchoSpacing()
data.echo_spacing_to_one_over_rbw_factor=1.2;
if data.tps(1)==999 || (numel(data.tps) > data.epi_dims(5))
    data.epi_tpoes=1:data.epi_dims(5);
else
    data.epi_tpoes=data.tps;
    data.epi_dims(5)=size(data.epi_tpoes,2);
end

%EPI,TE
data.epi_te = 1e-6*str2num(search_text_header_func(data.epi_header_file, 'alTE[0]'));
data.epi_te_string='epi';
switch data.poc_remove_additional_readout_gradient
    case 'ARC3'
        switch data.epi_dims(1)
            case 4
                data.epi_tpoe_string='1:1';
            case 5
                data.epi_tpoe_string=sprintf('1:%i',data.epi_dims(5)+1);
        end
    otherwise
        data.epi_tpoe_string=':';
end

data.epi_template_tpoe_string = '1';

%EPI,Acceleration
data.epi_acceleration = str2double(search_all_header_func(data.epi_header_file, 'Pat.lAccelFactPE'));

%EPI,RBW
data.epi_rbw = str2double(search_all_header_func(data.epi_header_file, 'PixelBandwidth:'));

%EPI,Effective echo spacing
data.epi_eES = 1/(data.epi_rbw*data.epi_acceleration);

if data.do_sdc == 1
    %GE,dims etc
    ge_hdr = load_nii_hdr(data.ge_filename_mag);
    data.ge_dims = ge_hdr.dime.dim;
    data.ge_pixdim = ge_hdr.dime.pixdim;
    data.ne=data.ge_dims(5);
    data.ge_nc=data.ge_dims(6);
    data.echoes_to_use = [1 3]; % to calculate fieldmaps from ge (use [1 2] for monopolar and [1 3] for bipolar)
    for j=1:data.ne
        data.TEs(j) = 1e-6*str2num(search_text_header_func(data.ge_header_file, sprintf('alTE[%s]', num2str(j-1))));
    end
    data.ge_te_diff=data.TEs(data.echoes_to_use(2))-data.TEs(data.echoes_to_use(1));
    data.ge_tpoes=1:data.ne;
    %   sep channel or combined?
    if data.ge_nc == 1
        %   which echoes to unwrap
        data.ge_tpoe_string=sprintf('[%i,%i]',data.echoes_to_use(1),data.echoes_to_use(2));
        data.ge_te_string=sprintf('[%.1f,%.1f]',1000*data.TEs(data.echoes_to_use(1)),1000*data.TEs(data.echoes_to_use(2)));
        data.ge_template_tpoe_string = sprintf('%i',data.echoes_to_use(1));
    else
        data.TEs = data.ge_te_diff;
        %   which echoes to unwrap
        data.ge_tpoe_string='1';
        data.ge_te_string=sprintf('%.1f',1000*data.ge_te_diff);
        data.ge_template_tpoe_string = '1';
        data.fm_option='first_echo';
    end    
end

