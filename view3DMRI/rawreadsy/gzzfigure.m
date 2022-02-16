
figure(31)
subaxis(3,6,1,'Spacing',0,'Margin',0)
imagesc(gz(:,:,sn),[-10 10])
axis off
axis image
% colormap(gray)
title('fitted Gz map')
subaxis(3,6,2,'Spacing',0,'Margin',0)
imagesc(gx(:,:,sn),[-10 10])
axis off
axis image
% colormap(gray)
title('fitted Gx map')
subaxis(3,6,3,'Spacing',0,'Margin',0)
imagesc(gy(:,:,sn),[-10 10])
axis off
axis image
% colormap(gray)
title('fitted Gy map')
subaxis(3,6,4,'Spacing',0,'Margin',0)
imagesc(gzz(:,:,sn),[-10 10])
axis off
axis image
% colormap(gray)
title('fitted Gzz map')
subaxis(3,6,5,'Spacing',0,'Margin',0)
imagesc(gzx(:,:,sn),[-10 10])
axis off
axis image
% colormap(gray)
title('fitted Gzx map')
subaxis(3,6,6,'Spacing',0,'Margin',0)
imagesc(gzy(:,:,sn),[-10 10])
axis off
axis image
% colormap(gray)
title('fitted Gzy map')

subaxis(3,6,7,'Spacing',0,'Margin',0)
imagesc(xyzrmap5(:,:,sn,3),[-10 10])
axis off
axis image
% colormap(gray)
title('fitted Gz map')
subaxis(3,6,8,'Spacing',0,'Margin',0)
imagesc(squeeze(xyzrmap5(:,:,sn,4)),[-10 10])
axis off
axis image
% colormap(gray)
title('fitted Gx map')
subaxis(3,6,9,'Spacing',0,'Margin',0)
imagesc(squeeze(xyzrmap5(:,:,sn,5)),[-10 10])
axis off
axis image
% colormap(gray)
title('fitted Gy map')
subaxis(3,6,10,'Spacing',0,'Margin',0)
imagesc(squeeze(xyzrmap5(:,:,sn,6)),[-10 10])
axis off
axis image
% colormap(gray)
title('fitted Gzz map')
subaxis(3,6,11,'Spacing',0,'Margin',0)
imagesc(squeeze(xyzrmap5(:,:,sn,7)),[-10 10])
axis off
axis image
% colormap(gray)
title('fitted Gzx map')
subaxis(3,6,12,'Spacing',0,'Margin',0)
imagesc(squeeze(xyzrmap5(:,:,sn,8)),[-10 10])
axis off
axis image
% colormap(gray)
title('fitted Gzy map')

subaxis(3,6,13,'Spacing',0,'Margin',0)
imagesc(squeeze(gz(:,:,sn))-squeeze(xyzrmap5(:,:,sn,3)),[-10 10])
axis off
axis image
% colormap(gray)
title('Difference Gz map')
subaxis(3,6,14,'Spacing',0,'Margin',0)
imagesc(squeeze(gx(:,:,sn))-squeeze(xyzrmap5(:,:,sn,4)),[-10 10])
axis off
axis image
% colormap(gray)
title('fitted Gx map')
subaxis(3,6,15,'Spacing',0,'Margin',0)
imagesc(squeeze(gy(:,:,sn))-squeeze(xyzrmap5(:,:,sn,5)),[-10 10])
axis off
axis image
% colormap(gray)
title('fitted Gy map')
subaxis(3,6,16,'Spacing',0,'Margin',0)
imagesc(squeeze(gzz(:,:,sn))-squeeze(xyzrmap5(:,:,sn,6)),[-10 10])
axis off
axis image
% colormap(gray)
title('fitted Gzz map')
subaxis(3,6,17,'Spacing',0,'Margin',0)
imagesc(squeeze(gzx(:,:,sn))-squeeze(xyzrmap5(:,:,sn,7)),[-10 10])
axis off
axis image
% colormap(gray)
title('fitted Gzx map')
subaxis(3,6,18,'Spacing',0,'Margin',0)
imagesc(squeeze(gzy(:,:,sn))-squeeze(xyzrmap5(:,:,sn,8)),[-10 10])
axis off
axis image
% colormap(gray)
title('fitted Gzy map')


