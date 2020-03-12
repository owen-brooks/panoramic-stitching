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


%%%%%% 3 %%%%%%
figure(2), hold on
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

figure(3), hold on
gray2 = rgb2gray(pic2);i = 1;new_im = gray1;pyramid2 = cell(16,1);
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

%%%%%% 4 %%%%%%
[all1, stable1] = keypoints(gray1, pyramid1);

figure(4), imshow(gray1), hold on
plot(all1(:,1),all1(:,2), 'ro', 'MarkerSize', 4);
hold off

figure(5), imshow(gray1), hold on
plot(stable1(:,1),stable1(:,2), 'ro', 'MarkerSize', 4);
hold off

[all2, stable2] = keypoints(gray2, pyramid2);

figure(6), imshow(gray2), hold on
plot(all2(:,1),all2(:,2), 'ro', 'MarkerSize', 4);
hold off

figure(7), imshow(gray2), hold on
plot(stable2(:,1),stable2(:,2), 'ro', 'MarkerSize', 4);
hold off


