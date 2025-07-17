load DigitsDataTrain.mat
load DigitsDataTest.mat

numTrainImages = numel(anglesTrain);
figure
idx = randperm(numTrainImages,20);
for i = 1:numel(idx)
    subplot(4,5,i)    
    imshow(XTrain(:,:,:,idx(i)))
end

figure
histogram(anglesTrain)
axis tight
ylabel('Counts')
xlabel('Rotation Angle')

layers = [
    imageInputLayer([28 28 1])
    convolution2dLayer(3,8,'Padding','same')
    batchNormalizationLayer
    reluLayer
    averagePooling2dLayer(2,'Stride',2)
    convolution2dLayer(3,16,'Padding','same')
    batchNormalizationLayer
    reluLayer
    averagePooling2dLayer(2,'Stride',2)
    convolution2dLayer(3,32,'Padding','same')
    batchNormalizationLayer
    reluLayer
    convolution2dLayer(3,32,'Padding','same')
    batchNormalizationLayer
    reluLayer
    dropoutLayer(0.2)
    fullyConnectedLayer(1)
    regressionLayer];

miniBatchSize  = 128;
validationFrequency = floor(numel(anglesTrain)/miniBatchSize);
options = trainingOptions('sgdm', ...
    'MiniBatchSize',miniBatchSize, ...
    'MaxEpochs',30, ...
    'InitialLearnRate',1e-3, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',0.1, ...
    'LearnRateDropPeriod',20, ...
    'Shuffle','every-epoch', ...
    'ValidationData',{XTest,anglesTest}, ...
    'ValidationFrequency',validationFrequency, ...
    'Plots','training-progress', ...
    'Verbose',false);

net = trainNetwork(XTrain,anglesTrain,layers,options);

net.Layers

YTest = predict(net,XTest);

predictionError = anglesTest - YTest;

thr = 10;
numCorrect = sum(abs(predictionError) < thr);
numTestImages = numel(anglesTest);

accuracy = numCorrect/numTestImages

squares = predictionError.^2;
rmse = sqrt(mean(squares))

figure
scatter(YTest,anglesTest,'+')
xlabel("Predicted Value")
ylabel("True Value")

hold on
plot([-60 60], [-60 60],'r--')

idx = randperm(numTestImages,49);
for i = 1:numel(idx)
    image = XTest(:,:,:,idx(i));
    predictedAngle = YTest(idx(i));  
    imagesRotated(:,:,:,i) = imrotate(image,predictedAngle,'bicubic','crop');
end

figure
subplot(1,2,1)
montage(XTest(:,:,:,idx))
title('Original')

subplot(1,2,2)
montage(imagesRotated)
title('Corrected')

