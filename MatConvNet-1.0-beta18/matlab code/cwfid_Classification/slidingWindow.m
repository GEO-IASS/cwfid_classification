close all
clear
clc

%define the size of the patches
dim = 51;
%define the stride of the sliding window
stride = 5;
%crop = 1, weed = 2, ground = 3
crop = 1;
weed = 2;
ground = 3;

% load the pre-trained CNN
net = cnn_cwfid();
%remove last layer: softmax  
net.layers{end}.type = 'softmax';
net.mode = 'test';

testingDir = fullfile(vl_rootnn, 'data', 'cwfid','testing');
testingSlidingWindowDir = fullfile(testingDir,'sliding window');

listing = dir(testingSlidingWindowDir);
listing=listing(~ismember({listing.name},{'.','..','Thumbs.db'}));
%get the testing image
for i=1 : size(listing,1)
    slidingWindowImTesting(:,:,:,i)=imread(fullfile(testingSlidingWindowDir,listing(i).name));
end


%for all the images
for i=1 : size(slidingWindowImTesting,4)
    cont1 = 1;
    for j=1 : stride : (size(slidingWindowImTesting,2)-dim)
       for k=1 : stride : (size(slidingWindowImTesting,1)-dim)
           %get the patches
           im(:,:,:,cont1) = single(imcrop(slidingWindowImTesting(:,:,:,i),...
               [j,k,dim-1,dim-1]));
           cont1 = cont1+1;
       end
    end
   
    res = vl_simplenn(net, im);
    scores = squeeze(gather(res(end).x)) ;
    [bestScore, best] = max(scores) ;
    
   I = reshape(best,int16((size(slidingWindowImTesting,1)-dim)/stride),...
        int16((size(slidingWindowImTesting,2)-dim)/stride));
    
   for s=1 : size(I,1)
        for v=1 : size(I,2)
            if I(s,v) == crop
               Im(s,v,:) = [0;255;0];
            end
            if I(s,v) == weed
               Im(s,v,:) = [255;0;0];
            end
            if I(s,v) == ground
               Im(s,v,:) =[0;0;0];
            end
        end
   end
    
   I = imresize(Im,[size(slidingWindowImTesting,1),size(slidingWindowImTesting,2)]);
   figure, imshow(I)
   
end