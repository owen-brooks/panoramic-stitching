clear, clf;

pic1 = imread('./pics/pic1.jpeg'); pic2 = imread('./pics/pic2.jpeg');
[h1,w1,~] = size(pic1); [h2,w2,~] = size(pic2);

%%%%%% 1 %%%%%%
pic1_pts = [375 750;1210 425;780 470;555 120;];
pic2_pts = [35 775; 890 450; 505 470;280 85;];

figure(1); hold on; imshow([pic1 pic2]);
for i = 1:4
    hold on;
    plot([pic1_pts(i, 1) w1+ pic2_pts(i, 1)], [pic1_pts(i, 2) pic2_pts(i, 2)], '.', 'MarkerSize', 30);
end
hold off;

%%%%%% 2 %%%%%%
figure(2);
pic1_pts(:,2) = h1-pic1_pts(:,2);pic2_pts(:,2) = h2-pic2_pts(:,2);
pic1_pts(:,1) = w1-pic1_pts(:,1);pic2_pts(:,1) = w2-pic2_pts(:,1);
blended_im = transform_and_blend(pic1, pic2, pic1_pts, pic2_pts);
imshow(blended_im)

%%%%%% 3 %%%%%%
figure(3), hold on
gray1 = rgb2gray(pic1);i = 1;new_im = gray1;pyramid1 = cell(16,1);
for octave = 1:4
    for scale = 1:4
        out = smooth_and_sample(gray1, new_im, octave, scale, 1.6);
        pyramid1{i} = out;
        subplot(4,4,i);imshow(out);axis on;
        i = i + 1;
        if scale == 4
            new_im = out;
        end
    end
end
hold off

figure(4), hold on
gray2 = rgb2gray(pic2);i = 1;new_im = gray2;pyramid2 = cell(16,1);
for octave = 1:4
    for scale = 1:4
        out = smooth_and_sample(gray2, new_im, octave, scale, 1.6);
        pyramid2{i} = out;
        subplot(4,4,i);imshow(out);axis on;
        i = i + 1;
        if scale == 4
            new_im = out;
        end
    end
end
hold off

% %%%%%% 4 %%%%%%
[all1, stable1] = keypoints(gray1, pyramid1);

figure(5), imshow(gray1), hold on
plot(all1(:,2),h1-all1(:,1), 'ro', 'MarkerSize', 4);
hold off

figure(6), imshow(gray1), hold on
plot(stable1(:,2),h1-stable1(:,1), 'ro', 'MarkerSize', 4);
hold off

[all2, stable2] = keypoints(gray2, pyramid2);

figure(7), imshow(gray2), hold on
plot(all2(:,2),h2-all2(:,1), 'ro', 'MarkerSize', 4);
hold off

figure(8), imshow(gray2), hold on
plot(stable2(:,2),h2-stable2(:,1), 'ro', 'MarkerSize', 4);
hold off

% %%%%%% 5 %%%%%%
figure(9);imshow([pic1 pic2]);
data_file = matfile('data.mat');stable1 = data_file.stable1;stable2 = data_file.stable2;
matches = match_keypoints(pic1, pic2, stable1, stable2, 0.998);
for i = 1:length(matches)
    x1 = stable1(matches(i,1),2);
    y1 = h1 - stable1(matches(i,1),1);
    
    x2 = stable2(matches(i,2),2);
    y2 = h2 - stable2(matches(i,2),1);
    
    hold on;
    plot([x1 w1+x2], [y1 y2], 'r', 'MarkerSize', 10)

end
hold off;

% %%%%%% 5 %%%%%%
kps1 = stable1(matches(:,1),:);kps2 = stable2(matches(:,2),:);
kp_used = ransac(kps1, kps2, 10);

figure(10);
k1 = kps1(kp_used,:);
k2 = kps2(kp_used,:);

% k1 = [k1(:,2) k1(:,1)];
% k2 = [k2(:,2) k2(:,1)];

blended_im = transform_and_blend(pic1, pic2, k2, k1);
imshow(blended_im)

figure(11);imshow([pic1 pic2]);

for i = 1:length(k1)
    x1 = k1(i,2);
    y1 = h1 - k1(i,1);
    
    x2 = k2(i,2);
    y2 = h2 - k2(i,1);
    
    hold on;
    plot([x1 w1+x2], [y1 y2], 'r', 'MarkerSize', 10)

end
hold off;







