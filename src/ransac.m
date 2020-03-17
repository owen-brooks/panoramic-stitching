function kp_used = ransac(kps1, kps2, N)
    scores = zeros(1,N);idxs = zeros(N,4);
    for i = 1:N
        % select 4 rand keypoint matches
        temp_idxs = randperm(length(kps1), 4);idxs(i,:) = temp_idxs;
        H = transformation_mat(kps1(temp_idxs,:), kps2(temp_idxs,:));
        pic2_upperLeft = [kps2' ; ones(1, size(kps2,1))];
        projectingUL = H * pic2_upperLeft;
        
        score = 0; % score is sum of euclidean dists
        for ii=1:size(kps2,1)
            temp_kps2 = [projectingUL(1,ii) projectingUL(2,ii)]./projectingUL(3,ii);
            temp_kps1 = [kps1(ii,1) kps1(ii,2)];
            score  = score + sqrt(sum(temp_kps1-temp_kps2).^2);
        end
        scores(i) = score;
    end
    
    
    [~,i] = min(scores);
    kp_used = idxs(i,:);

end


function H = transformation_mat(kp1, kp2)
    A = [];
    for i =1:size(kp1,1)
        A = [A; -kp1(i,1) -kp1(i,2) -1 0 0 0 kp2(i,1)*kp1(i,1) kp2(i,1)*kp1(i,2) kp2(i,1)];
        A = [A; 0 0 0 -kp1(i,1) -kp1(i,2) -1 kp2(i,2)*kp1(i,1) kp2(i,2)*kp1(i,2) kp2(i,2)];
    end
    [~, ~, eigenV] = svd(transpose(A)*A);
    h = eigenV(:, end);
    % then reshape it to a 3x3, and you have your transformation matrix H
    h = h/sum(h);
    H = reshape(h, [3,3]).';
end