pic1 = imread('./pics/pic1.jpeg'); pic2 = imread('./pics/pic2.jpeg');
[h1,w1,~] = size(pic1); [h2,w2,~] = size(pic2);

%%%%%% 1 %%%%%%
pic1_pts = [375 750;1210 425;780 470;555 120;];
pic2_pts = [35 775; 890 450; 505 470;280 85;];

figure(1); hold on; imshow([pic1 pic2]);
for i = 1:pic1_pts
    hold on;
    plot([pic1_pts(i, 1) w1+ pic2_pts(i, 1)], [pic1_pts(i, 2) pic2_pts(i, 2)], '.', 'MarkerSize', 30);
end
hold off;

%%%%%% 2 %%%%%%

