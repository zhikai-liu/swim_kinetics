function [Ed_image,BIM,area_ErIM,area_BIM,core,core_max_dist]=fish_tracking(imageStack,numberOfImages,fname)
    %% background substraction
    BG=max(imageStack,[],3);
    for i=1:size(imageStack,3)
        imageStack(:,:,i)=BG-imageStack(:,:,i);
    end
    %% find the core and fore-aft direction by erosion filter
    core = zeros(numberOfImages,2);
    core_max_dist = zeros(numberOfImages,2);
    area_ErIM=zeros(numberOfImages,1);
    area_BIM=zeros(numberOfImages,1);
    range=1:numberOfImages;
    BIM=logical(imageStack);
    Ed_image=logical(imageStack);
    for i = range
        %% binarize the image for each frame
        BIM(:,:,i) = imbinarize(imageStack(:,:,i),0.09);
        SE=strel('disk',3);
        BIM(:,:,i)=imclose(BIM(:,:,i),SE); %fill the gaps to obtain a continuous fish shape with a 2 pixels radius disk filter
        area_BIM(i)= sum(sum(BIM(:,:,i)));
        %% erode the image with the filter SE
        SE =strel('disk',20); % erosion filter with 14 pixels radius disk, adjust it according to zoom factor
        Ed_image(:,:,i) = imerode(BIM(:,:,i),SE);
        %% finding the centroids of continuous area in the eroded image and size of the areas
        S = regionprops(Ed_image(:,:,i),'Area','Centroid');
        if length(S)~=1
            warning(['frame ' num2str(i) ' has more than one centroid']);
        end
        %% if there are several areas, find the one with the largest size, which is usually the fish
        [~,index]=sort([S.Area]);
        %% use the centroid of that area as the core of the fish
        core(i,:)=S(index(end)).Centroid;
        area_ErIM(i)=S(index(end)).Area;
        %% find the boundary of that area and calculate the max distance from the core to the boundary 
        [B,L]=bwboundaries(Ed_image(:,:,i),'noholes');
        Uni=unique(L);
        Count=histc(reshape(L,1,[]),Uni(2:end));
        [~,index]=max(Count);
        core_b=B{index};
        P =[core_b(:,2)-core(i,1),core_b(:,1)-core(i,2)];
        D=sqrt(P(:,1).^2+P(:,2).^2);
        [~,index]=max(D);
        % core_max_dist is the coordinate of the point on the boundary
        % that is the furtherest from the fish, which is usually the
        % bladder of the fish. Bladder to the core is the anterior
        % direction
        core_max_dist(i,:)=P(index,:)+core(i,:);
    end
    %% plot trace of tracking
    figure;
    plot(core(range,1),core(range,2),'*-')
    title(fname);
end