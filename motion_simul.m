function [ output_ks ] = motion_simul(ks, trajec, motion)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% trjectory matrix size = size(ks,2) * size(ks,3)
%%%% motion size = max(trajec) * 6
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if max(abs(motion(:))) == 0
    output_ks = ks;
    return
end

[yres, xres, zres] = size(ks);
ms = size(motion,1);
ts = max(trajec(:));

if ts > ms
    error(strcat('motion matrix size [',num2str(ms),'] =/=',' max value of trajectory matrix [', num2str(ts),']'))
end
clear ms

output_ks = ks;

% linear phase 생성
ky = linspace(-pi,pi-2*pi*(1/yres),yres);
kx = linspace(-pi,pi-2*pi*(1/xres),xres);
kz = linspace(-pi,pi-2*pi*(1/zres),zres);


tra_y = size(trajec,1);
tra_z = size(trajec,2);
for zz = 1:tra_z
    for yy = 1:tra_y
        
        ii = trajec(yy,zz);

        transy = motion(ii,1);  % transy
        transx = motion(ii,2); % transx
        transz = motion(ii,3); % transz

        yaw = motion(ii,4); % yaw
        pitch = motion(ii,5); % pitch
        roll = motion(ii,6); % roll
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%% translation %%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Fourier shift theorem을 통해 linear phase를 만들고 해당하는 phase를 곱해줌
        y_phase = exp(-1i * ky * transy).';      
        x_phase = exp(-1i * kx * transx);        

        xy_phase = y_phase(yy) * x_phase;
        output_ks(yy,:, zz) = (xy_phase .* squeeze(ks(yy,:, zz)));
        
        
        tmp = fftc(output_ks, zres,3);
        
        z_phase = exp(-1i * kz * transz).';       
        tmp(yy,:, zz) = (z_phase(zz) .* squeeze(tmp(yy,:, zz)));
        
   
        tmp1 = ifftc(tmp, zres, 3);
        clear tmp

        %%%%%%%%%%%%%%%%%%%%%%%%%%% rotation %%%%%%%%%%%%%%%%%%%%%%%%%%%
        % image domain으로 다시 영상을 만든후, motion parameter 만큼 회전시킨후, 다시 kspace
        % domain으로 만들어 모션 발생한 부을 대체함.
        temp_vol = ifft2c(tmp1);
        clear tmp1

        if yaw
            for ll = 1:yres
                temp_cor_view =  imrotate(transpose(squeeze(temp_vol(ll,:,:))),yaw,'bilinear','crop');
                temp_vol(ll,:,:) = transpose(temp_cor_view);
            end
        end
        if pitch
            for cc = 1:xres
                temp_sag_view = imrotate(transpose(squeeze(temp_vol(:,cc,:))),pitch,'bilinear','crop');
                temp_vol(:,cc,:) = transpose(temp_sag_view);
            end
        end
        if roll
%             for zz = 1:zres
                temp_vol(:,:,zz) = imrotate(temp_vol(:,:,zz),roll,'bilinear','crop');
%             end
        end
        
        tmp_ks = fft2c(temp_vol);
        clear temp_vol
        
        output_ks(yy,:,zz) = tmp_ks(yy,:,zz);
        clear tmp_ks
        
        
    end
end
        
        
    
    