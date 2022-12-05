% standalone script to make avi and mosaics from selected slices
clearvars
padl=20;
padlr=4; % number of voxels between slices
padud=6; % number of voxels between rows
imthresh=0.3;
frame=[10 5 5 5]; %frame width: top, bottom, left, right
framerate=25;
results_dir='/media/uqsrob35/SR_EXT4/refill';
for run=1:3
    switch run
        case 1
            writefile='/home/uqsrob35/Dropbox/current_papers/SR_REFILL_DDC/sfig2_time-series_video_s1/s1.avi';
            sub='sub1';
            slices=[8,11,14,17,21,27,29];
            imthresh=.4;
            frame=[10 5 5 5]; %frame width: top, bottom, left, right
        case 2
            writefile='/home/uqsrob35/Dropbox/current_papers/SR_REFILL_DDC/sfig3_time-series_video_s2/s2.avi';
            sub='sub2';
            slices=[12,15,18,20,23,27,31];
            imthresh=0.3;
            frame=[10 5 5 5]; %frame width: top, bottom, left, right
        case 3
            writefile='/home/uqsrob35/Dropbox/current_papers/SR_REFILL_DDC/sfig4_time-series_video_s3/s3.avi';
            sub='sub3';
            slices=[11,15,18,21,23,25,30];
            imthresh=0.45;
            frame=[5 5 5 5]; %frame width: top, bottom, left, right
    end
    n_slices=numel(slices);
    imrow1_fn=fullfile(results_dir, 'results',sub,'fMRI_hands_refill/distortion_correction','epi_m_mc.nii');
    imrow2_fn=fullfile(results_dir, 'results',sub,'fMRI_hands_refill/distortion_correction','epi_m_sdc_bet_mc.nii');
    imrow3_fn=fullfile(results_dir, 'results',sub,'fMRI_hands_refill/distortion_correction','epi_m_ddc_bet_mc.nii');    

    im1_hdr=load_nii_hdr(imrow1_fn);
    x=im1_hdr.dime.dim(2);
    y=im1_hdr.dime.dim(3);
    z=im1_hdr.dime.dim(4);
    ntp=im1_hdr.dime.dim(5);
    
    row1nii=load_untouch_nii(imrow1_fn);
    row1nii=thresh(row1nii.img,imthresh,frame);
    no_rows=1;
    if isvar('imrow2_fn')
        no_rows=no_rows+1; 
        row2nii=load_untouch_nii(imrow2_fn); 
        row2nii=thresh(row2nii.img,imthresh,frame);
    end
    
    if isvar('imrow3_fn')
        no_rows=no_rows+1; 
        row3nii=load_untouch_nii(imrow3_fn); 
        row3nii=thresh(row3nii.img,imthresh,frame);
    end
     
    v = VideoWriter(writefile);
    v.FrameRate = framerate;
    open(v)
    
    im=zeros(x*n_slices+padl,no_rows*y+2*padud);
    for j=1:ntp
        for i=1:n_slices
            im((i-1)*x+padl+1:i*x+padl,1:y)=row3nii(:,:,slices(i),j);   
            im((i-1)*x+padl+1:i*x+padl,y+padud+1:2*y+padud)=row2nii(:,:,slices(i),j);   
            im((i-1)*x+padl+1:i*x+padl,2*(y+padud)+1:3*y+2*padud)=row1nii(:,:,slices(i),j);   
        end
        im2=insertText(im,[2*(y+padl) 4; y+padl+15 4; 20 4],{'Original','Static DC','Dynamic DC'});
        im3(:,:,j)=squeeze(im2(:,:,1));
        im2=rot90(im2);
        
        % slow it down bodge
        for k=1:5
            writeVideo(v,im2);
        end
        
    end    
    
    close(v)
    
    save_nii(make_nii(im3),fullfile(results_dir, 'results',sub,'fMRI_hands_refill/distortion_correction','original_sdc_ddc_mosaic.nii'));
  
    fprintf('Wrote %s\n', writefile);
    a=999;
end

fprintf(' *** finished ***\n');

function img=thresh(img,threshold,frame)
x=size(img,1);
y=size(img,2);
temp=img;
img(:,:,:,:)=0;
img(frame(3)+1:x-frame(4),frame(2)+1:y-frame(1),:,:)=temp(frame(3)+1:x-frame(4),frame(2)+1:y-frame(1),:,:);
clear temp
img(img<0)=0;
img(img>threshold*max(vector(img)))=threshold*max(vector(img));
img=rescale(img,0,1);
end


