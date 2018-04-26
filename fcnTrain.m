function fcnTrain(varargin)
%FNCTRAIN Train FCN model using MatConvNet

run matconvnet/matlab/vl_setupnn ;
addpath matconvnet/examples ;

% experiment and data paths
opts.expDir = 'data/fcn32s-500-33cases_MICCAI2009' ;
opts.dataDir = 'data/33cases_MICCAI2009' ;
opts.modelType = 'fcn32s' ;
opts.sourceModelPath = 'data/models/imagenet-vgg-verydeep-16.mat' ;
[opts, varargin] = vl_argparse(opts, varargin) ;

% experiment setup
opts.imdbPath = fullfile(opts.expDir, 'imdb.mat') ;
opts.imdbStatsPath = fullfile(opts.expDir, 'imdbStats.mat') ;
opts.vocEdition = '09' ;
opts.vocAdditionalSegmentations = false ;

opts.numFetchThreads = 1 ; % not used yet

% training options (Stochastic Gradient Descent SGD)
% opts.train = struct(]) ;%edited by mR
opts.train.gpus = [] ;%edited by mR
[opts, varargin] = vl_argparse(opts, varargin) ;

trainOpts.batchSize = 20 ;
trainOpts.numSubBatches = 10 ;
trainOpts.continue = true ;
trainOpts.gpus = [] ;
trainOpts.prefetch = true ;
trainOpts.expDir = opts.expDir ;
trainOpts.learningRate = 0.0001 * ones(1,50) ;
trainOpts.numEpochs = numel(trainOpts.learningRate) ;

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
if any(strcmp(opts.modelType, {'fcn16s', 'fcn8s'}))
  % upgrade model to FCN16s
  net = fcnInitializeModel16s(net) ;
end
if strcmp(opts.modelType, 'fcn8s')
  % upgrade model fto FCN8s
  net = fcnInitializeModel8s(net) ;
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
bopts.classWeights = ones(1,3,'single') ;
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
