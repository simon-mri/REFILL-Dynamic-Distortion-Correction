function image_nii=create_mosaic_function(image_nii)
% create_mosiac.m - Create tiled "mosaic" images from volumes
%
%   Most fMRI programs use 4D matrices (x,y,z,t) in NIfTI format.
%   It can be useful to reduce the number of dimension from 4 to 3 by tiling all slices (z) into a "mosaic" image for each time point (t).
%   Flicking through the 3rd dimension (e.g. in mricro http://www.cabiatl.com/mricro/mricro/index.html)
%   allows the time course of each slice to be visualised.
%   Useful for assessing motion and artefacts in fMRI time series
%   Can also be used to create a 2D mosaic of all the slices in a 3D volume, e.g. for structural imaging
%
%   Simon Robinson. 2/May/2011. simon.robinson@meduniwien.ac.at
%
%   function form 2021
%   Credit: includes many functions from Jimmy Shen's excellent NIfTI toolbox (file exchange # 8797)

%%%%USER-Defined section ends here%%%%

x=image_nii.hdr.dime.dim(2);
y=image_nii.hdr.dime.dim(3);
z=image_nii.hdr.dime.dim(4);
t=image_nii.hdr.dime.dim(5);
pixdim=image_nii.hdr.dime.pixdim;
classname=class(image_nii.img);

%   find the side length of the mosaic image (number of images)
mossideL = ceil(sqrt(z));
%   create the 3D mosaic matrix
mosmat = zeros(mossideL*x,ceil(z/mossideL)*y,t, classname);
for k=1:t
    for j=1:z
        col=ceil(z/mossideL)-(floor((j-1)/mossideL)+1)+1;
        row=j-floor((j-1)/mossideL)*(mossideL);
        mosmat((row-1)*x+1:row*x,(col-1)*y+1:col*y,k)=image_nii.img(:,:,j,k);
    end
end
image_nii=make_nii(mosmat);
image_nii.hdr.dime.pixdim=pixdim;

