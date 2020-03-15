function targetImage = transform_and_blend(pic1, pic2, pic1_pts, pic2_pts)
    % pic1 is defined as base image
    % pic2 is image that will be projected onto pic1
    [h1,w1,~] = size(pic1); [h2,w2,~] = size(pic2);
    
% Projected Value
    H = transformation_mat(pic1_pts, pic2_pts);
    
    pic2_upperLeft = [0; 0; 1];
    pic2_bottomLeft = [0; size(pic2, 1); 1];
    pic2_upperRight = [size(pic2, 2); 0; 1];
    pic2_bottomRight = [size(pic2, 2); size(pic2, 1); 1];

    projectingUL = H * pic2_upperLeft;
    projectingUL = projectingUL./projectingUL(3);
        
    projectingBL = H * pic2_bottomLeft;
    projectingBL = projectingBL./ projectingBL(3);
    
    projectingUR = H * pic2_upperRight;
    projectingUR = projectingUR./projectingUR(3);
    
    projectingBR = (H) * pic2_bottomRight;
    projectingBR = projectingBR./projectingBR(3);
    
    
    % The height of this image should be the maximum of the base image's height or the
    % maximum projected y value from the other image. The width will be equal to the maximum of the
    % base image's width or the maximum projected x value from the other image.

    % Decide dimensions of target image
    projectingMaxX = max([projectingUL(1), projectingUR(1), projectingBL(1), projectingBR(1)]);
    projectingMaxY = max([projectingUL(2), projectingUR(2), projectingBL(2), projectingBR(2)]);
    targetImageWidth = max(w1, projectingMaxX);
    targetImageHeight = max(h1, projectingMaxY);

    % Distance from projection origin to base origin in target image coordinates 
    DX = projectingUL(1);DY = projectingUL(2);

    % Matrix to move from target image to base image
    translationMatrix = [1, 0, DX;
                        0, 1, DY;
                        0, 0 , 1;];

    targetImage = zeros(round(targetImageHeight), round(targetImageWidth), 3);

    for width = 1 : round(targetImageWidth)
        for height = 1 : round(targetImageHeight)
            % use translationMatrix to go to base image, return (bX, bY, channel)
            bp = inv(translationMatrix) * [width; height; 1];
            bp = round(bp / bp(3));

            % use H to go from base image to image 2, return (pX, pY, channel)
            pp = H * [bp(1); bp(2); 1];
            pp = round(pp./ pp(3));

            % if bX AND bY is positive, record the value at base(bX, bY, channel)
            if (w2 >= pp(1) && pp(1) > 0) && (h2 >= pp(2) && pp(2) > 0)
                 if (w1 >= bp(1) && bp(1) > 0) && (h1 >= bp(2) && bp(2) > 0)
                    alpha = .7;
                    blend = ((1-alpha) * pic2(bp(2), bp(1), :)) + (alpha * pic1(pp(2), pp(1), :));
                    targetImage(height, width, :) = blend;
                 else
                     targetImage(height, width, :) = pic1(pp(2), pp(1), :);
                 end
                 
            elseif (w1 >= bp(1) && bp(1) > 0) && (h1 >= bp(2) && bp(2) > 0)
                targetImage(height, width, :) = pic2(bp(2), bp(1), :);
            end

        end
        
    end
    targetImage = uint8(targetImage);
end



function H = transformation_mat(kp1, kp2)
    A = [];
    for i =1:length(kp1)
        A = [A; -kp1(i,1) -kp1(i,2) -1 0 0 0 kp2(i,1)*kp1(i,1) kp2(i,1)*kp1(i,2) kp2(i,1)]
        A = [A; 0 0 0 -kp1(i,1) -kp1(i,2) -1 kp2(i,2)*kp1(i,1) kp2(i,2)*kp1(i,2) kp2(i,2)]
    end
    [~, ~, eigenV] = svd(transpose(A)*A);
    h = eigenV(:, end);
    % then reshape it to a 3x3, and you have your transformation matrix H
    h = h/sum(h);
    H = reshape(h, [3,3]).';
end