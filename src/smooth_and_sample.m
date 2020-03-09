function im = smooth_and_sample(orig_im, last_im, octave, scale, sigma_orig)
    [h,w] = size(last_im);
    new_h = h; new_w = w;
    if octave > 1
        new_h = round(h*(1/2));new_w = round(w*(1/2));       
    end
    im = nn_resample(new_h, new_w, orig_im);
    
    sigma = (2^(octave-1))*(sqrt(2)^(scale-1))*sigma_orig;
    kern = gauss_kern(ceil(3*sigma), sigma);
    im = conv2(im, kern, 'same')/255;
    

end

function kernel = gauss_kern(n, sigma)
    kernel = zeros(n);
    for row = 1:n
        for col = 1:n
            x = abs(row-ceil(n/2));y = abs(col-ceil(n/2));
            kernel(row,col) = exp(-x.^2/(2*sigma^2)-y.^2/(2*sigma^2));
        end
    end
    kernel = kernel./(sum(kernel(:)));
end

function out = nn_resample(new_h, new_w, im)
    [h,w] = size(im);out = zeros(new_h, new_w, 'uint8');
    for row=1:new_h
        for col=1:new_w
            yi = row*(h/new_h); xi = col*(w/new_w);
            out(row,col ) = im(round(yi), round(xi));
        end
    end
end