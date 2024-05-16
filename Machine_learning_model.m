% Database creation
imds = imageDatastore('Leaf_Disease_Dataset', 'IncludeSubfolders', true, 'LabeSource', 'foldernames');
disp(imds);

% splitting data
% 80% training data, 20% testing data
trainRatio = 0.8; 

% Partitioning of labels
c = cvpartition(imds.Labels, 'HoldOut', 1 - trainRatio);

% Training Indices and Testing Indices
trainIdx = training(c);
testIdx = test(c);

% Partition the ImageDatastore into training and testing sets
traindata = subset(imds, trainIdx);
testdata = subset(imds, testIdx);

% Defining network layers
layers = [
    imageInputLayer([256 256 3])
    convolution2dLayer(5, 20)
    reluLayer
    maxPooling2dLayer(2, 'Stride', 2)
    fullyConnectedLayer(5)
    softmaxLayer
    classificationLayer
];

% Defining training options
options = trainingOptions('rmsprop', ...
    'Plots', 'training-progress', ...
    'LearnRateSchedule', 'piecewise', ...
    'MaxEpochs', 30, ...
    'LearnRateDropFactor', 0.4, ...
    'LearnRateDropPeriod', 7, ...
    'MiniBatchSize', 300);

% Training the network
net = trainNetwork(traindata, layers, options);
save net net

% Training completed
helpdlg('Training completed');
