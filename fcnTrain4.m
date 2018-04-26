function fcnTrain(varargin)
%FNCTRAIN Train FCN model using MatConvNet
 
run ../matconvnet/matlab/vl_setupnn ;
addpath ../matconvnet/examples ;

% experiment and data paths
opts.expDir = 'H:/nana/data/fcn4s-500-33cases_MICCAI2009_adam_60-1_1lr_3phases_128_4loss-o' ;
opts.dataDir = 'H:/nana/data/33cases_MICCAI2009' ;
opts.modelType = 'fcn4s' ;
opts.sourceModelPath = 'H:/nana/data/models/imagenet-vgg-verydeep-16.mat' ;
[opts, varargin] = vl_argparse(opts, varargin) ;

% experiment setup
opts.imdbPath = fullfile(opts.expDir, 'imdb.mat') ;
opts.imdbStatsPath = fullfile(opts.expDir, 'imdbStats.mat') ;
opts.vocEdition = '09' ;
opts.vocAdditionalSegmentations = false ;

opts.numFetchThreads = 1 ; % not used yet

% training options (Stochastic Gradient Descent SGD)
% opts.train = struct(]) ;%edited by mR
opts.train.gpus = 1 ;%edited by mR
[opts, varargin] = vl_argparse(opts, varargin) ;

trainOpts.batchSize = 60 ;%每个batch的样本数
trainOpts.numSubBatches = 1 ; %每个batch分成多少个subbatch
trainOpts.continue = true ;
trainOpts.gpus = 1 ;
trainOpts.prefetch = true ;
trainOpts.expDir = opts.expDir ;
trainOpts.numEpochs = 50;
trainOpts.learningRate = 0.0001 * ones(1,trainOpts.numEpochs);%edited by mR 原始为0.0001
% trainOpts.learningRate(trainOpts.numEpochs/2+1:trainOpts.numEpochs) = 0.0001 ;%edited by mR 原始为0.0001
% trainOpts.learningRate(trainOpts.numEpochs) = trainOpts.learningRate(1) * 0.01;
% for i = 2 :trainOpts.numEpochs - 1
%     afa = i / trainOpts.numEpochs ;
%     trainOpts.learningRate(i) =  (1 - afa) * trainOpts.learningRate(i) + afa  * trainOpts.learningRate(trainOpts.numEpochs);
% %     trainOpts.learningRate(i) =  trainOpts.learningRate(i)/(1 + i * trainOpts.numEpochs);
% %     trainOpts.learningRate(i) =  trainOpts.learningRate(i) * log(-(i * trainOpts.numEpochs));
% end

% -------------------------------------------------------------------------
% Setup data
% -------------------------------------------------------------------------

% Get PASCAL VOC 12 segmentation dataset plus Berkeley's additional
% Map the dataset to imdb   %edited by mR
% segmentations
if exist(opts.imdbPath)
  imdb = load(opts.imdbPath) ;
else
  imdb = vocSetup('dataDir', opts.dataDir, ...
    'edition', opts.vocEdition, ...
    'includeTest', false, ...
    'includeSegmentation', true, ...
    'includeDetection', false) ;
  if opts.vocAdditionalSegmentations
    imdb = vocSetupAdditionalSegmentations(imdb, 'dataDir', opts.dataDir) ;
  end
  mkdir(opts.expDir) ;
  save(opts.imdbPath, '-struct', 'imdb') ;
end

% Get training and test/validation subsets
% trainval = randperm(270);
% train = trainval(1:210);
% val = trainval(211:270);
train = find(imdb.images.set == 1 & imdb.images.segmentation) ;
val = find(imdb.images.set == 2 & imdb.images.segmentation) ;

% Get dataset statistics
if exist(opts.imdbStatsPath)
  stats = load(opts.imdbStatsPath) ;
else
  stats = getDatasetStatistics(imdb) ;
  save(opts.imdbStatsPath, '-struct', 'stats') ;
end

% -------------------------------------------------------------------------
% Setup model
% -------------------------------------------------------------------------

% Get initial model from VGG-VD-16
net = fcnInitializeModel('sourceModelPath', opts.sourceModelPath) ;
if any(strcmp(opts.modelType, {'fcn16s', 'fcn8s', 'fcn4s'}))
  % upgrade model to FCN16s
  net = fcnInitializeModel16s(net) ;
end
if any(strcmp(opts.modelType, {'fcn8s', 'fcn4s'}))
  % upgrade model fto FCN8s
  net = fcnInitializeModel8s(net) ;
end
if strcmp(opts.modelType, 'fcn4s')
  % upgrade model fto FCN4s
  net = fcnInitializeModel4s(net) ;
end
net.meta.normalization.rgbMean = stats.rgbMean ;
net.meta.classes = imdb.classes.name ;

% -------------------------------------------------------------------------
% Train
% -------------------------------------------------------------------------

% Setup data fetching options
bopts.numThreads = opts.numFetchThreads ;
bopts.labelStride = 1 ;
bopts.labelOffset = 1 ;
bopts.classWeights = ones(1,2,'single') ;
bopts.rgbMean = stats.rgbMean ; 
bopts.useGpu = numel(opts.train.gpus) > 0 ;

% Launch SGD
info = cnn_train_dag(net, imdb, getBatchWrapper(bopts), ...
                     trainOpts, ....
                     'train', train, ...
                     'val', val, ...
                     opts.train) ;

% -------------------------------------------------------------------------
function fn = getBatchWrapper(opts)
% -------------------------------------------------------------------------
fn = @(imdb,batch) getBatch(imdb,batch,opts,'prefetch',nargout==0) ;
