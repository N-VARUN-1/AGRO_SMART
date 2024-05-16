% Network Loading ('net.mat' file)
netFile = 'net.mat'; 
if isfile(netFile)
    load(netFile, 'net');
else
    error('Network file not found');
end


[filename, pathname] = uigetfile('*.*');

if isequal(filename, 0) || isequal(pathname, 0)
    warndlg('Cancellation Requested');
else
    g = imread(fullfile(pathname, filename));
    g = imresize(g, [256 256]);

    % RGB format verification
    if size(g, 3) ~= 3
        error('RGB format not available');
    end

    % Classify the image
    try
        tag = classify(net, g);
        disp(['Disease: ', char(tag)]);
    catch ME
        disp('ERROR! No Classification of image');
        disp(ME.message);
        return;
    end

    
    subplot(2, 2, 1); imshow(g); title("Original Image");
   
    a = imread(fullfile(pathname, filename));
    a = imresize(a, [256 256]);
    c = rgb2hsv(a);

    H = c(:,:,1);
    S = c(:,:,2);
    V = c(:,:,3);

    f = fspecial('Gaussian', [9, 9]);
    filter = imfilter(H, f);
    subplot(2, 2, 2); imshow(filter); title("Filtered Image");

    % Differentiation of tags according to the filter rate
    switch char(tag)
        case 'Bacteria'
            bw = filter > 0.17 & filter < 0.65;
        case 'Fungi'
            bw = filter > 0.15 & filter < 0.5;
        case 'Nematodes'
            bw = filter > 0.08 & filter < 0.5;
        case 'Virus'
            bw = filter > 0.08 & filter < 0.3;
        case 'Normal - No disease found!'
            bw = filter > 0.1 & filter < 0.5;
        otherwise
            bw = false(size(filter));
    end

    Bw = ~bw;

    % Defining Size limits
    switch char(tag)
        case 'Bacteria'
            BW2 = bwareafilt(Bw, [5 1000]);
        case 'Fungi'
            BW2 = bwareafilt(Bw, [5 1000]);
        case 'Nematodes'
            BW2 = bwareafilt(Bw, [5 600]);
        case 'Virus'
            BW2 = bwareafilt(Bw, [5 2000]);
        case 'Normal'
            BW2 = bwareafilt(Bw, [5 2000]);
        otherwise
            BW2 = Bw;
    end

    subplot(2, 2, 3); 
    imshow(Bw);
    title("Binarized Image");

    subplot(2, 2, 4);
    imshow(BW2); 
    title("Image with Spots");

    cc = bwconncomp(BW2);
    Spots = cc.NumObjects;
    disp(['Number of Spots: ', num2str(Spots)]);

    % Fuzzy interface Loading
    fisObject = readfis("Fuzzy.fis");

    % Input for fuzzy interface system
    inputFIS = Spots;  

    try
        rate = evalfis(fisObject, inputFIS);
        disp(['Health Percentage: ', num2str(rate), ' %']);
    catch ME
        disp('Error evaluating the fuzzy inference system:');
        disp('ERROR! Fuzzy Evaluatio failed');
        disp(ME.message);
    end
end
