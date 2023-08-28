clear all;
%% 2D Version of the Yang algorithm
%% Get File
pathName = 'C:\Users\swths\Downloads';
fileName = '0404Binary.tif';
hInfo = imfinfo(strcat(pathName,'\',fileName));

% Set parameters.
imageHeight = hInfo(1).Height;
imageWidth = hInfo(1).Width;

%% Import the binary image
FileName = strcat(pathName,'\',fileName);
Image(:,:) =imread(FileName);

C = double(Image);% turn image into matrix
%% Definitions
a1=1;
a2=imageHeight; % pixel number in the x-direction
b1=1;
b2=imageWidth; % pixel number in the y-directioin
Re(100)=0; % allocated stream for data storage, this is slightly stupid

%% Non-local means denoising

%% Binarization

%% Invert image


%% Critical circle search loop
% This loop goes over every pixel in the image. The value l is counted up,
% if the pixel is not closer to the boundary than the already detected
% circle, and if a virtual circle with the diameter l around the pixel is not interfering with a fiber pixel.
C0=0*C;
C1=0*C;
for i=a1:a2 % begin to find the critic radius for each unit-valued pixel, and store the value of critic
    %     radius in the matrix “C0”
    for j=b1:b2
        if C(i,j)~=0 %if pixel is in the void
            circleSearchBreak=1;     % set  loop break condition to 1, search continues until condition = 0
            l=0;        % start with l=0, l is the size of the critical circle (largest void around the current pixel)
            while circleSearchBreak>0    %while pixel is in the void
                C0(i,j)=l+0.5; % add 0.5 to C0 matrix
                l=l+1;              % count up l+1, whenever the conditions below are not fulfilled (e.g. search has found a fiber pixel, l is critical circle around every pixel
                if (i-l)<=(a1-1)||(j-l)<=(b1-1)||(i+l)>=(a2+1)||(j+l)>=(b2+1) % this is boundary conditions at the corner of the image
                    circleSearchBreak=0;
                end
                if (circleSearchBreak~=0)
                    for aa=(i-l):(i+l)  % search the area with the size +-l around the current pixel
                        for bb=(j-l):(j+l) 
                            if sqrt((aa-i)^2+(bb-j)^2)<=l  % if pixel in subimage is within the circle with the radius of l around the current pixel in localtion i,j,k
                                if C(aa,bb)==0                   % if pixel in subimage is not in void, stop the while loop (stop searching for bigger circle
                                    circleSearchBreak=0;
                                end
                            end
                        end
                    end
                end
            end
        end    
    end
    i;
end
% finish the critic radius-finding procedure

figure
subplot(1,2,1)
h = pcolor(C0(:,:));
c = colorbar('eastoutside');
set(h, 'EdgeColor', 'none');
c.Label.String = 'Maximum ball size in [px]';
%%
maxDiameter=max(C0,[],'all')-0.5; % get the maximum of C0 and subtract the 0.5 from above
for dp=maxDiameter:-1:0 % begin to locate the surrounding pixels, start at maximum diameter
    for i=a1:a2      % loop over whole image
        for j=b1:b2    
            if C0(i,j)==dp+0.5    % if C0 entry is identical with current search circle size
                for aa=(i-dp):(i+dp)    % search in area of current circle size around current pixel
                    for bb=(j-dp):(j+dp)
                        
                        if sqrt((aa-i)^2+(bb-j)^2)<=dp % if pixel in subimage is within the circle with the radius of dp around the current pixel in localtion i,j,k
                            if C1(aa,bb)==0  % if C1 is 0
                                C1(aa,bb)=dp+1; % enter current circle +1 in C1
                            end
                        end
                        
                    end
                end
            end 
        end
    end
end
% finish the surrounding pixel-finding procedure
subplot(1,2,2)
h = pcolor(C1(:,:));
c = colorbar('eastoutside');
set(h, 'EdgeColor', 'none');
c.Label.String = 'Maximum ball size in [px]';
%% This loop goes over the image and counts how many entries exist with a size dp. Could be used to make a histgram.
for dp=0:maxDiameter % begin to store the pixel number at different critic radius into a stream named “Re”
    for i=a1:a2 % loop over the whole image ANOTHER time. Couldn't this be done all in one go?
        for j=b1:b2
            if C1(i,j)==dp+1
                Re(dp+1)=Re(dp+1)+1;
            end 
        end
    end
end % complete the procedure
% RGB_label = label2rgb(C1(:,:,10),'jet'); % paint pore area with different colors according to pore size
% figure, imshow(RGB_label) % show the colored pore configuration









