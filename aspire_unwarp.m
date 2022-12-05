function img_uw = aspire_unwarp(vsm, img)

imdim=size(img);
typeofimg = class(img);
switch typeofimg
    case 'int16'
        img=single(img);
end

% try to avoid non-unique values in the vsm, which cause interp1 to strike
vsm=double(vsm);
vsm=vsm+1E-5*rand(size(vsm));

if numel(imdim)>3
    tps=imdim(4);
else
    tps=1;
end

mx=imdim(1);
my=imdim(2);
if numel(imdim)>2
    mz=imdim(3);
else
    mz=1;
end

yi = 1:my;
img_uw=zeros(mx,my,mz,tps);
fprintf('Unwarping image, tp=');
for t = 1:tps
    if t<tps
        fprintf('%i,', t);
    else
        fprintf('%i\n', t);
    end
    for x = 1:mx
        for z=1:mz
            gridvector= double(yi + vsm(x,:,z,t));
            gridvector=checkgridvector(gridvector);
            % linear, spline, pchip, makima,
            img_uw(x,:,z,t) = interp1( gridvector, img(x,:,z,t), yi, 'linear', 'extrap');
        end
    end
end
end

function gridvector=checkgridvector(gridvector)
[v, w] = unique(gridvector, 'stable' );
while (size(v,2)<size(gridvector,2))
    duplicate_indices = setdiff( 1:numel(gridvector), w );
    gridvector(duplicate_indices)=gridvector(duplicate_indices)+1E-5*rand;
    [v, w] = unique(gridvector, 'stable' );
    fprintf(' caught duplicate values with checkgridvector\n');
end
end
