pic1 = imread('./pics/pic1.jpeg'); pic2 = imread('./pics/pic2.jpeg');
[h1,w1,~] = size(pic1); [h2,w2,~] = size(pic2);

%%%%%% 1 %%%%%%
% pic1_pts = [375 750;1210 425;780 470;555 120;];
% pic2_pts = [35 775; 890 450; 505 470;280 85;];
% 
% figure(1); hold on; imshow([pic1 pic2]);
% for i = 1:4
%     hold on;
%     plot([pic1_pts(i, 1) w1+ pic2_pts(i, 1)], [pic1_pts(i, 2) pic2_pts(i, 2)], '.', 'MarkerSize', 30);
% end
% hold off;

%%%%%% 2 %%%%%%


%%%%%% 3 %%%%%%
figure(2);gray1 = rgb2gray(pic1);i = 1;new_im = gray1;
for octave = 1:4
    for scale = 1:4
        out = smooth_and_sample(gray1, new_im, octave, scale, 1.6);
        subplot(4,4,i);imshow(out);axis on;
        i = i + 1;
        if scale == 4
            new_im = out;
        end
    end
end

figure(3);gray2 = rgb2gray(pic2);i = 1;new_im = gray1;
for octave = 1:4
    for scale = 1:4
        out = smooth_and_sample(gray2, new_im, octave, scale, 1.6);
        subplot(4,4,i);imshow(out);axis on;
        i = i + 1;
        if scale == 4
            new_im = out;
        end
    end
end

