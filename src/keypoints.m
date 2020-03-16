function [all, stable] = keypoints(orig, pyramid)
    all = local_maximas(pyramid);
    size(all)
    stable = remove_edge(orig, all);
    size(stable)
    stable = remove_too_close(orig, stable, 20);
    size(stable)
    stable = remove_patch(double(orig), stable, 2);
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
        [rows, cols] = find(f(:,:,2) == 1);
        maximas = [maximas ; [rows, cols].*2^(i-1)];
    end   
    maximas = unique(maximas, 'rows');
end

function new = remove_edge(im, old)
    edge_im = edge(im);
    [rows, cols] = find(edge_im == 1);
    new = setdiff(old, [rows, cols], 'rows');
end


function new = remove_too_close(im, old, thres)
    [h, w] = size(im);new = old;
    % row
    new(new(:, 1) < thres, :) = [];
    new(new(:, 1) > h-thres, :) = [];
    
    % col
    new(new(:, 2) < thres, :) = [];
    
    new(new(:, 2) > w-thres, :) = [];
end


function new =  remove_patch(im, old, thres)
    new = old;s = zeros(length(old),1);
    for i = 1:length(old)
        s(i) = std(neighbors(im, old(i,1),old(i,2)));
    end
    new(s > thres,:)=[];
end



function desc = neighbors(im, row, col)

    desc = im(row-4:row+4,col-4:col+4,:);
    desc = desc(:);
end
