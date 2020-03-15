function matches = match_keypoints(pic1, pic2, points1, points2, thres)
    desc1 = zeros(length(points1), 243);desc2 = zeros(length(points2), 243);

    for i = 1:length(points1)
        desc1(i, :) = describe(pic1, points1(i,2), points1(i,1));
    end
    for i = 1:length(points2)
        desc2(i, :) = describe(pic2, points2(i,2), points2(i,1));
    end
    
    [match1, match2] = best_matches(desc1,desc2);
    l = length(match1);
    
    % normalize scores
    match1(:,3) = (match1(:,3)-min(match1(:,3)))/(max(match1(:,3))- min(match1(:,3)));
    match2(:,3) = (match2(:,3)-min(match2(:,3)))/(max(match2(:,3))- min(match2(:,3)));
    all = match1;
    % apply thres
    match1(match1(:,3) < thres,:) = [];
    match2(match2(:,3) < thres,:) = [];
    
    match1 = match1(:,1:2);match2 = match2(:,1:2); % drop scores
    matches = intersect(match1,match2, 'rows');
    
    matches(:,2) = matches(:,2)-l;
end

function desc = describe(im, row, col)
    filter = zeros(size(im));
    filter(row,col,2) = 1;
    desc = im(convn(filter, ones(9,9,3), 'same') > 0);
end

function [match1, match2] = best_matches(set1, set2)
    l1 = length(set1); l2 = length(set2);
    match1 = zeros(l1, 3);match2 = zeros(l2, 3);
    for i = 1:l1
        v1=set1(i,:);
        for ii = 1:l2
            v2= set2(ii,:);
            sim = dot(v1,v2)/norm(v1)/norm(v2);
            
            if sim > match1(i,3)
                match1(i, :) = [i l1 + ii sim];
                
            end
            if sim > match2(ii, 3)
                match2(ii,:) = [i l1 + ii sim];
            end
        end
    end
end