function targetImage = transform_and_blend(pic1, pic2, pic1_pts, pic2_pts)
    % Projected Guess
    xHat_1 = pic2_pts(1, 1);
    yHat_1 = pic2_pts(1, 2);

    xHat_2 = pic2_pts(2, 1);
    yHat_2 = pic2_pts(2, 2);

    xHat_3 = pic2_pts(3, 1);
    yHat_3 = pic2_pts(3, 2);

    xHat_4 = pic2_pts(4, 1);
    yHat_4 = pic2_pts(4, 2);

    % Observed Value
    x_1 = pic1_pts(1, 1);
    y_1 = pic1_pts(1, 2);

    x_2 = pic1_pts(2, 1);
    y_2 = pic1_pts(2, 2);

    x_3 = pic1_pts(3, 1);
    y_3 = pic1_pts(3, 2);

    x_4 = pic1_pts(4, 1);
    y_4 = pic1_pts(4, 2);

    A = [-x_1, -y_1, -1, 0, 0, 0, xHat_1 * x_1, xHat_1 * y_1, xHat_1;
        0, 0, 0, -x_1, -y_1, -1, yHat_1 * x_1, yHat_1 * y_1, yHat_1;
        -x_2, -y_2, -1, 0, 0, 0, xHat_2 * x_2, xHat_2 * y_2, xHat_2;
        0, 0, 0, -x_2, -y_2, -1, yHat_2 * x_2, yHat_2 * y_2, yHat_2;
        -x_3, -y_3, -1, 0, 0, 0, xHat_3 * x_3, xHat_3 * y_3, xHat_3;
        0, 0, 0, -x_3, -y_3, -1, yHat_3 * x_3, yHat_3 * y_3, yHat_3;
        -x_4, -y_4, -1, 0, 0, 0, xHat_4 * x_4, xHat_4 * y_4, xHat_4;
        0, 0, 0, -x_4, -y_4, -1, yHat_4 * x_4, yHat_4 * y_4, yHat_4;];

    [left, sigma, right] = svd(transpose(A) * A);
    diag = [];

    % find SMALLEST value in diagonal of s
    for i = 1:size(sigma)
        diag(i) = sigma(i, i);
    end

    [smallest, i] = min(diag);
    % Whatever column that value is in, take the column of l, and that is our h
    % values
    h = left(:, i);
    % then reshape it to a 3x3, and you have your transformation matrix H
    H = reshape(h, [3,3]);

    upperLeft = [0, 0, 1];
    bottomLeft = [0, size(pic2, 1), 1];
    upperRight = [size(pic2, 2), 0, 1];
    bottomRight = [size(pic2, 2), size(pic2, 1), 1];

    projectingUL = upperLeft * H;
    projectingBL = bottomLeft * H;
    projectingUR = upperRight * H;
    projectingBR = bottomRight * H;

    % The height of this image should be the maximum of the base image's height or the
    % maximum projected y value from the other image. The width will be equal to the maximum of the
    % base image's width or the maximum projected x value from the other image.

    % Decide dimensions of target image
    baseImageHeight = size(pic1, 1);
    projectedImageHeight = max(baseImageHeight - projectingBL(2), baseImageHeight - projectingBR(2));
    targetImageHeight = max(baseImageHeight, projectedImageHeight);

    baseImageWidth = size(pic1, 2);
    projectedImageWidth = max(baseImageWidth - projectingUR(1), baseImageWidth - projectingBR(1));
    targetImageWidth = max(baseImageWidth, projectedImageWidth);

    projectedImageHeight = round(projectedImageHeight);
    projectedImageWidth = round(projectedImageWidth);

    % Distance offsets of projection on base 
    % DX = targetImage_origin_x - baseImage_origin_x
    DX = projectingUL(1);
    % DY = targetImage_origin_y - baseImage_origin_y
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
                basePixelLocation = translationMatrix * [width; height; 1]
                H
                % use H to go from base image to projected, return (pX, pY, channel)
                projectedPixelLocation = H * [basePixelLocation(1); basePixelLocation(2); 1]

                %if bX AND bY is positive, record the value at base(bX, bY, channel)
                if basePixelLocation(1) > 0 && basePixelLocation(2) > 0
                    targetImage(height, width, channel) = 1;
                end

                % if pX AND pY is positive, record the value at projected(pX, pY, channel)
                if projectedPixelLocation(1) > 0 && projectedPixelLocation(2) > 0
                    targetImage(height, width, channel) = 2;
                end

                % if both are positive, blend them

            end
        end
    end
end