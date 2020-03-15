function targetImage = transform_and_blend(pic1, pic2, pic1_pts, pic2_pts)
    % pic1 is defined as base image
    % pic2 is image that will be projected onto pic1
    
% Projected Value
    xHat_1 = pic2_pts(1, 1);
    yHat_1 = pic2_pts(1, 2);

    xHat_2 = pic2_pts(2, 1);
    yHat_2 = pic2_pts(2, 2);

    xHat_3 = pic2_pts(3, 1);
    yHat_3 = pic2_pts(3, 2);

    xHat_4 = pic2_pts(4, 1);
    yHat_4 = pic2_pts(4, 2);
 
% Base Value
    x_1 = pic1_pts(1, 1);
    y_1 = pic1_pts(1, 2);

    x_2 = pic1_pts(2, 1);
    y_2 = pic1_pts(2, 2);

    x_3 = pic1_pts(3, 1);
    y_3 = pic1_pts(3, 2);

    x_4 = pic1_pts(4, 1);
    y_4 = pic1_pts(4, 2);

    A = [-x_1, -y_1, -1, 0, 0, 0, xHat_1 * x_1, xHat_1 .* y_1, xHat_1;
        0, 0, 0, -x_1, -y_1, -1, yHat_1 * x_1, yHat_1 .* y_1, yHat_1;
        
        -x_2, -y_2, -1, 0, 0, 0, xHat_2 * x_2, xHat_2 .* y_2, xHat_2;
        0, 0, 0, -x_2, -y_2, -1, yHat_2 * x_2, yHat_2 .* y_2, yHat_2;
        
        -x_3, -y_3, -1, 0, 0, 0, xHat_3 * x_3, xHat_3 .* y_3, xHat_3;
        0, 0, 0, -x_3, -y_3, -1, yHat_3 * x_3, yHat_3 .* y_3, yHat_3;
        
        -x_4, -y_4, -1, 0, 0, 0, xHat_4 * x_4, xHat_4 .* y_4, xHat_4;
        0, 0, 0, -x_4, -y_4, -1, yHat_4 * x_4, yHat_4 .* y_4, yHat_4;];

    [~, ~, eigenV] = svd(transpose(A)*A);
    h = eigenV(:, end);
    % then reshape it to a 3x3, and you have your transformation matrix H
    h = h/sum(h);
    H = reshape(h, [3,3]).';
    
    pic2_upperLeft = [0, 0, 1];
    pic2_bottomLeft = [0, size(pic2, 1), 1];
    pic2_upperRight = [size(pic2, 2), 0, 1];
    pic2_bottomRight = [size(pic2, 2), size(pic2, 1), 1];

    projectingUL = pic2_upperLeft * inv(H);
    projectingUL(1) = projectingUL(1) / projectingUL(3);
    projectingUL(2) = projectingUL(2) / projectingUL(3);
        
    projectingBL = pic2_bottomLeft * inv(H);
    projectingBL(1) = projectingBL(1) / projectingBL(3);
    projectingBL(2) = projectingBL(2) / projectingBL(3);
    
    projectingUR = pic2_upperRight * inv(H);
    projectingUR(1) = projectingUR(1) / projectingUR(3);
    projectingUR(2) = projectingUR(2) / projectingUR(3);
    
    projectingBR = pic2_bottomRight * inv(H);
    projectingBR(1) = projectingBR(1) / projectingBR(3);
    projectingBR(2) = projectingBR(2) / projectingBR(3);
    
    % The height of this image should be the maximum of the base image's height or the
    % maximum projected y value from the other image. The width will be equal to the maximum of the
    % base image's width or the maximum projected x value from the other image.

    % Decide dimensions of target image
    projectingMaxX = max([projectingUL(1), projectingUR(1), projectingBL(1), projectingBR(1)]);
    projectingMaxY = max([projectingUL(2), projectingUR(2), projectingBL(2), projectingBR(2)]);
    targetImageWidth = max(size(pic1, 2), projectingMaxX);
    targetImageHeight = max(size(pic1, 1), projectingMaxY);

    % Distance from projection origin to base origin in target image coordinates 
    DX = projectingUL(1);
    DY = projectingUL(2);

    % Matrix to move from target image to base image
    translationMatrix = [1, 0, DX;
                        0, 1, DY;
                        0, 0 , 1;];

    targetImage = zeros(round(targetImageHeight), round(targetImageWidth), 3);
    for channel = 1 : 3
        for width = 1 : round(targetImageWidth)
            for height = 1 : round(targetImageHeight)
                % use translationMatrix to go to base image, return (bX, bY, channel)
                basePixelLocation = inv(translationMatrix) * [width; height; 1];
                basePixelLocation = basePixelLocation / basePixelLocation(3);
                
                % use H to go from base image to image 2, return (pX, pY, channel)
                projectedPixelLocation = H * [basePixelLocation(1); basePixelLocation(2); 1];
                projectedPixelLocation(1) = projectedPixelLocation(1) / projectedPixelLocation(3);
                projectedPixelLocation(2) = projectedPixelLocation(2) / projectedPixelLocation(3);
                
                % Round
                basePixelLocation = round(basePixelLocation);
                projectedPixelLocation = round(projectedPixelLocation);
                
                % if bX AND bY is positive, record the value at base(bX, bY, channel)
                if (basePixelLocation(1,1) > 0 && basePixelLocation(2,1) > 0)
%                     targetImage(height, width, channel) = pic1(basePixelLocation(1), basePixelLocation(2), channel);
                    targetImage(height, width, channel) = 0;
                end

                % if pX AND pY is positive, record the value at projected(pX, pY, channel)
                if (projectedPixelLocation(1,1) > 0 && projectedPixelLocation(2,1) > 0)
%                     targetImage(height, width, channel) = pic2(projectedPixelLocation(1), projectedPixelLocation(2), channel);
                    targetImage(height,width,channel) = 255;
                end

                % if both are positive, blend them

            end
        end
    end
    
    % Testing the projection on base
%     projectingXY = [projectingUL(1) projectingUL(2);
%     projectingBL(1) projectingBL(2);
%     projectingUR(1) projectingUR(2);
%     projectingBR(1) projectingBR(2);];
%     lines = insertShape(targetImage, 'Line', [projectingXY(1,1) projectingXY(1,2) projectingXY(2,1) projectingXY(2,2) projectingXY(4,1) projectingXY(4,2) projectingXY(3,1) projectingXY(3,2) projectingXY(1,1) projectingXY(1,2)], 'Color', 'red', 'LineWidth', 5);
%     imshow(lines);
end