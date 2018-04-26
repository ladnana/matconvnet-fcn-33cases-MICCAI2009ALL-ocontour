function y = getBatch(imdb, images, varargin)
% GET_BATCH  Load, preprocess, and pack images for CNN evaluation

opts.imageSize = [256, 256] - 128 ;
opts.numAugments = 1 ;
opts.transformation = 'none' ;
opts.rgbMean = [] ;
opts.rgbVariance = zeros(0,3,'single') ;
opts.labelStride = 1 ;
opts.labelOffset = 0 ;
opts.classWeights = ones(1,21,'single') ;
opts.interpolation = 'bilinear' ;
opts.numThreads = 1 ;
opts.prefetch = false ;
opts.useGpu = false ;
opts = vl_argparse(opts, varargin);

if opts.prefetch
  % to be implemented
  ims = [] ;
  labels = [] ;
  return ;
end

if ~isempty(opts.rgbVariance) && isempty(opts.rgbMean)
  opts.rgbMean = single([128;128;128]) ;
end
if ~isempty(opts.rgbMean)
  opts.rgbMean = reshape(opts.rgbMean, [1 1 3]) ;
end

% space for images
ims = zeros(opts.imageSize(1), opts.imageSize(2), 3, ...
  numel(images)*opts.numAugments, 'single') ;

% space for labels
lx = opts.labelOffset : opts.labelStride : opts.imageSize(2) ;
ly = opts.labelOffset : opts.labelStride : opts.imageSize(1) ;
labels = zeros(numel(ly), numel(lx), 1, numel(images)*opts.numAugments, 'single') ;
classWeights = [0 opts.classWeights(:)'] ;

im = cell(1,numel(images)) ;

si = 1 ;

for i=1:numel(images)

  % acquire image
  if isempty(im{i})
      Temp_type = imdb.images.name{images(i)};
%       Temp_type = Temp_type(7:10);
      sz = size(Temp_type);
      Temp_type = Temp_type(sz(end) - 8 :sz(end)-5);
      Temp_num = str2num(Temp_type);
      if Temp_num < 34
          rgbPath = sprintf(imdb.paths.image2, imdb.images.name{images(i)}) ;
          rgb = load(rgbPath) ;
          rgb = rgb.picture;
      else
          rgbPath = sprintf(imdb.paths.image, imdb.images.name{images(i)}) ;
          rgb = dicomread(rgbPath) ;
      end
      labelsPath = sprintf(imdb.paths.classSegmentation, imdb.images.name{images(i)}) ;
%     rgbPath = sprintf(imdb.paths.image, imdb.images.name{images(i)}) ;
%     rgb = vl_imreadjpeg({rgbPath}) ;
    rgb = single(rgb);
%     if opts.rgbMean(:,:,1)<50
%         rgb = ((rgb-min(rgb(:)))/(max(rgb(:))-min(rgb(:))))*255;
%     end
    anno = imread(labelsPath) ;
  else
    rgb = im{i} ;
  end
  if size(rgb,3) == 1  % ��ʾͼ���ǻҶ�ͼ�� ����3ΪRGB��ɫͼ
    rgb = cat(3, rgb, rgb, rgb) ;
  end

  % crop & flip
  h = size(rgb,1) ;
  w = size(rgb,2) ;
  for ai = 1:opts.numAugments
    sz = opts.imageSize(1:2) ;
    scale = max(h/sz(1), w/sz(2)) ;
%     scale = scale .* (1 + (rand(1)-.5)/5) ;

    sy = round(scale * ((1:sz(1)) - sz(1)/2) + h/2) ;
    sx = round(scale * ((1:sz(2)) - sz(2)/2) + w/2) ;
    if rand > 0.5, sx = fliplr(sx) ; end

    okx = find(1 <= sx & sx <= w) ;
    oky = find(1 <= sy & sy <= h) ;
    if ~isempty(opts.rgbMean)
      ims(oky,okx,:,si) = bsxfun(@minus, rgb(sy(oky),sx(okx),:), opts.rgbMean) ;
    else
      ims(oky,okx,:,si) = rgb(sy(oky),sx(okx),:) ;
    end

    tlabels = zeros(sz(1), sz(2), 'uint8') + 255 ;
    tlabels(oky,okx) = anno(sy(oky),sx(okx)) ;
    tlabels = single(tlabels(ly,lx)) ;
    tlabels = mod(tlabels + 1, 256) ; % 0 = ignore, 1 = bkg
    labels(:,:,1,si) = tlabels ;
    si = si + 1 ;
  end
end
if opts.useGpu
  ims = gpuArray(ims) ;
end
y = {'input', ims, 'label', labels} ;

