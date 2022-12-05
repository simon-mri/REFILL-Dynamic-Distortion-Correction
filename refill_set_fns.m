function data=refill_set_fns(data)

[status,msg]=mkdir(data.write_dir);
if status~=1, error(msg); end
data.write_dir_dc=fullfile(data.write_dir,'distortion_correction');
[status,msg]=mkdir(data.write_dir_dc);
if status~=1, error(msg); end

data.write_dir_steps=fullfile(data.write_dir_dc, 'steps');
[status,msg]=mkdir(data.write_dir_steps);
if status~=1, error(msg); end
if data.do_sdc == 1
    data.write_dir_comp=fullfile(data.write_dir_dc, 'evaluation');
    [status,msg]=mkdir(data.write_dir_comp);
    if status~=1, error(msg); end
end

data.aspire='no';
data=refill_aspire_set_fns(data);



