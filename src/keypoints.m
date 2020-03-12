function [all, stable] = keypoints(orig, pyramid)
    all = local_maximas(pyramid);
    size(all)
    stable = remove_edge(orig, all);
    size(stable)
    stable = remove_to_close(orig, stable, 20);
    size(stable)
    stable = remove_patch(orig, stable, 2);
    size(stable)
end


function maximas = local_maximas(pyramid1)
    maximas = [];
    for i = 1:4
        scale = (i-1)*4;
        dog1 = cell2mat(pyramid1(2+scale))-cell2mat(pyramid1(1+scale));
        dog2 = cell2mat(pyramid1(3+scale))-cell2mat(pyramid1(2+scale));
        dog3 = cell2mat(pyramid1(4+scale))-cell2mat(pyramid1(3+scale));
        dog = cat(3,dog1,dog2,dog3);
        f = imregionalmax(dog, ones(3,3,3));
        [row, col] = find(f(:,:,2) == 1);
        maximas = [maximas ; col.*2^(i-1) row.*2^(i-1)];
    end   
    maximas = unique(maximas, 'rows');
end

function new = remove_edge(im, old)
    edge_im = edge(im);
    [row, col] = find(edge_im == 1);
    new = setdiff(old, [col row], 'rows');
end


function new = remove_to_close(im, old, thres)
    [h, w] = size(im);new = [];
    new = old;
    new(new(:, 1) < thres, :)= [];
    new(new(:, 2) < thres, :)= [];
    new(new(:, 1) > w-thres, :)= [];
    new(new(:, 2) > h-thres, :)= [];
end


function new =  remove_patch(im, old, thres)
    new = [zeros(size(old))];
    for i = 1:length(old)
        if std2(neighbors(im, old(i,1),old(i,2))) < thres
            new(i,:) = old(i,:);
        end
    end
    new(new(:,1) == 0,:)=[];
end


function vals = neighbors(im, row, col)
    filter = zeros(size(im));
    filter(row,col) = 1;
    vals = im(conv2(filter, ones(5,5), 'same') > 0);
end
