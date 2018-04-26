function imdb = vocSetup(varargin)
opts.edition = '09' ;
opts.dataDir = fullfile('data','33cases_MICCAI2009') ;
opts.archiveDir = fullfile('data','archives') ;
opts.includeDetection = false ;
opts.includeSegmentation = true ;
opts.includeTest = false ;
opts = vl_argparse(opts, varargin) ;


% Source images and classes
imdb.paths.image = esc(fullfile(opts.dataDir, 'CropDCMImages-i-123+132+up-scaledown-middleshape+HVmirror-clahe', '%s.dcm')) ;
imdb.paths.image2 = esc(fullfile(opts.dataDir, 'CropDCMImages-i-123+132+up-scaledown-middleshape+HVmirror-clahe', '%s.mat')) ;
% imdb.paths.image = esc(fullfile(opts.dataDir, 'DCMImages', '%s.dcm')) ;
imdb.sets.id = uint8([1 2 3]) ;
imdb.sets.name = {'train', 'val', 'test'} ;
imdb.classes.id = uint8(1) ;
imdb.classes.name = {'icontour'} ;
imdb.classes.images = cell(1) ;
imdb.images.id = [] ;
imdb.images.name = {} ;
imdb.images.set = [] ;
index = containers.Map() ;
[imdb, index] = addImageSet(opts, imdb, index, 'train', 1) ;
[imdb, index] = addImageSet(opts, imdb, index, 'val', 2) ;
if opts.includeTest, [imdb, index] = addImageSet(opts, imdb, index, 'test', 3) ; end

% Source segmentations
if opts.includeSegmentation
  n = numel(imdb.images.id) ;
  imdb.paths.classSegmentation = esc(fullfile(opts.dataDir, 'CropSegmentationClass-i+123+132+up-scaledown-middleshape+HVmirror', '%s.png')) ;
  imdb.images.segmentation = false(1, n) ;
  [imdb, index] = addSegmentationSet(opts, imdb, index, 'train', 1) ;
  [imdb, index] = addSegmentationSet(opts, imdb, index, 'val', 2) ;
  if opts.includeTest, [imdb, index] = addSegmentationSet(opts, imdb, index, 'test', 3) ; end
end

% Compress data types
imdb.images.id = uint32(imdb.images.id) ;
imdb.images.set = uint8(imdb.images.set) ;
for i=1
  imdb.classes.images{i} = uint32(imdb.classes.images{i}) ;
end

% Source detections
if opts.includeDetection
  imdb.aspects.id = uint8(1:5) ;
  imdb.aspects.name = {'front', 'rear', 'left', 'right', 'misc'} ;
  imdb = addDetections(opts, imdb) ;
end

% Check images on disk and get their size
imdb = getImageSizes(imdb) ;

% -------------------------------------------------------------------------
function [imdb, index] = addImageSet(opts, imdb, index, setName, setCode)
% -------------------------------------------------------------------------
j = length(imdb.images.id) ;
for ci = 1:length(imdb.classes.name)
  className = imdb.classes.name{ci} ;
  annoPath = fullfile(opts.dataDir, 'ImageSets', 'Main', ...
    [className '_' setName '.txt']) ;
  fprintf('%s: reading %s\n', mfilename, annoPath) ;
  [names,labels] = textread(annoPath, '%s %f') ;
  for i=1:length(names)
    if ~index.isKey(names{i})
      j = j + 1 ;
      index(names{i}) = j ;
      imdb.images.id(j) = j ;
      imdb.images.set(j) = setCode ;
      imdb.images.name{j} = names{i} ;
      imdb.images.classification(j) = true ;
    else
      j = index(names{i}) ;
    end
    if labels(i) > 0, imdb.classes.images{ci}(end+1) = j ; end
  end
end

% -------------------------------------------------------------------------
function [imdb, index] = addSegmentationSet(opts, imdb, index, setName, setCode)
% -------------------------------------------------------------------------
segAnnoPath = fullfile(opts.dataDir, 'ImageSets', 'Segmentation', [setName '.txt']) ;
fprintf('%s: reading %s\n', mfilename, segAnnoPath) ;
segNames = textread(segAnnoPath, '%s') ;
j = numel(imdb.images.id) ;
for i=1:length(segNames)
  if index.isKey(segNames{i})
    k = index(segNames{i}) ;
    imdb.images.segmentation(k) = true ;
    imdb.images.set(k) = setCode ;
  else
    j = j + 1 ;
    index(segNames{i}) = j ;
    imdb.images.id(j) = j ;
    imdb.images.set(j) = setCode ;
    imdb.images.name{j} = segNames{i} ;
    imdb.images.classification(j) = false ;
    imdb.images.segmentation(j) = true ;
  end
end

% -------------------------------------------------------------------------
function imdb = getImageSizes(imdb)
% -------------------------------------------------------------------------
for j=1:numel(imdb.images.id)
    imdb.images.size(:,j) = uint16([128 ; 128]) ;
%   info = dicominfo(sprintf(imdb.paths.image, imdb.images.name{j})) ;
%   imdb.images.size(:,j) = uint16([info.Width ; info.Height]) ;
%   fprintf('%s: checked image %s [%d x %d]\n', mfilename, imdb.images.name{j}, info.Height, info.Width) ;
end

% -------------------------------------------------------------------------
function imdb = addDetections(opts, imdb)
% -------------------------------------------------------------------------
rois = {} ;
k = 0 ;
fprintf('%s: getting detections for %d images\n', mfilename, numel(imdb.images.id)) ;
for j=1:numel(imdb.images.id)
  fprintf('.') ; if mod(j,80)==0,fprintf('\n') ; end
  name = imdb.images.name{j} ;   
  annoPath = fullfile(opts.dataDir, 'Annotations', [name '.xml']) ;
  if ~exist(annoPath, 'file')
    if imdb.images.classification(j) && imdb.images.set(j) ~= 3
      warning('Could not find detection annotations for image ''%s''. Skipping.', name) ;
    end
    continue ;
  end
  
  doc = xmlread(annoPath) ;
  x = parseXML(doc, doc.getDocumentElement()) ;
  
  %   figure(1) ; clf ;
  %   imagesc(imread(sprintf(imdb.paths.image,imdb.images.name{j}))) ;
  
  for q = 1:numel(x.object)
    xmin = sscanf(x.object(q).bndbox.xmin,'%d') ;
    ymin = sscanf(x.object(q).bndbox.ymin,'%d') ;
    xmax = sscanf(x.object(q).bndbox.xmax,'%d') - 1 ;
    ymax = sscanf(x.object(q).bndbox.ymax,'%d') - 1 ;
    
    k = k + 1 ;
    roi.id = k ;
    roi.image = imdb.images.id(j) ;
    roi.class = find(strcmp(x.object(q).name, imdb.classes.name)) ;
    roi.box = [xmin;ymin;xmax;ymax] ;
    roi.difficult = logical(sscanf(x.object(q).difficult,'%d')) ;
    roi.truncated = logical(sscanf(x.object(q).truncated,'%d')) ;
    if isfield(x.object(q),'occluded')
      roi.occluded = logical(sscanf(x.object(q).occluded,'%d')) ;
    else
      roi.occluded = false ;
    end
    switch x.object(q).pose
      case 'frontal', roi.aspect = 1 ;
      case 'rear', roi.aspect = 2 ;
      case {'sidefaceleft', 'left'}, roi.aspect = 3 ;
      case {'sidefaceright', 'right'}, roi.aspect = 4 ;
      case {'','unspecified'}, roi.aspect = 5 ;
      otherwise, error(sprintf('Unknown view ''%s''', x.object(q).pose)) ;
    end
    rois{k} = roi ;
    
    %     hold on ;
    %     label=sprintf('%s %s d:%d t:%d o:%d',...
    %       imdb.classes.name{roi.class}, ...
    %       imdb.aspects{roi.aspect}, ...
    %       roi.difficult, ...
    %       roi.truncated, ...
    %       roi.occluded) ;
    %     plotbox(roi.box,'label',label) ;
    %     drawnow ;
  end
end
fprintf('\n') ;

rois = horzcat(rois{:}) ;
imdb.objects = struct(...
    'id', uint32([rois.id]), ...
    'image', uint32([rois.image]), ...
    'class', uint8([rois.class]), ...
    'box', single([rois.box]), ...
    'difficult', [rois.difficult], ...
    'truncated', [rois.truncated], ...
    'occluded', [rois.occluded], ...
    'aspect', uint8([rois.aspect])) ;

% -------------------------------------------------------------------------
function value = parseXML(doc, x)
% -------------------------------------------------------------------------
text = {''} ;
opts = struct ;
if x.hasChildNodes
  for c = 1:x.getChildNodes().getLength()
    y = x.getChildNodes().item(c-1) ;
    switch y.getNodeType()
      case doc.TEXT_NODE
        text{end+1} = lower(char(y.getData())) ;
      case doc.ELEMENT_NODE
        param = lower(char(y.getNodeName())) ;
        if strcmp(param, 'part'), continue ; end
        value = parseXML(doc, y) ;
        if ~isfield(opts, param)
          opts.(param) = value ;
        else
          opts.(param)(end+1) = value ;
        end
    end
  end
  if numel(fieldnames(opts)) > 0
    value = opts ;
  else
    value = strtrim(horzcat(text{:})) ;
  end
end

% -------------------------------------------------------------------------
function str=esc(str)
% -------------------------------------------------------------------------
str = strrep(str, '\', '\\') ;
