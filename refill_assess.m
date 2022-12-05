function refill_assess(image_nii,fn)

pixdim=image_nii.hdr.dime.pixdim;

mag_mosaic=create_mosaic_function(image_nii);
centre_and_save_nii(mag_mosaic,strrep(fn,'.nii','_mosaic.nii'),pixdim);
% motion-correct:
fn_mc=strrep(fn,'.nii','_mc.nii');
mc_string=sprintf('mcflirt -in %s -refvol 0 -o %s',fn, fn_mc);
[status,cmdout]=unix(mc_string);
if status~=0, error(cmdout); end
image_nii=load_untouch_nii(fn_mc);
mag_mosaic=create_mosaic_function(image_nii);
centre_and_save_nii(mag_mosaic,strrep(fn_mc,'.nii','_mosaic.nii'),pixdim);
centre_and_save_nii(make_nii(mean(single(image_nii.img),4)), strrep(fn_mc,'.nii','_mean.nii'), pixdim);
centre_and_save_nii(make_nii(std(single(image_nii.img),0,4)), strrep(fn_mc,'.nii','_std.nii'), pixdim);
