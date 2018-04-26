function net = fcnInitializeModel2s(net)
%FCNINITIALIZEMODEL8S Initialize the FCN-4S model from FCN-8S

%% Remove the last layer
net.removeLayer('deconv4') ;

%% Add the first deconv layer
filters = single(bilinear_u(4, 1, 2)) ;%not sure that do 'crop' need to be modified ?
net.addLayer('deconv4bis', ...
  dagnn.ConvTranspose('size', size(filters), ...
                      'upsample', 2, ...
                      'crop', 1, ...
                      'hasBias', false), ...
             'x47', 'x48', 'deconv4bisf') ;
f = net.getParamIndex('deconv4bisf') ;  
net.params(f).value = filters ;
net.params(f).learningRate = 0 ;
net.params(f).weightDecay = 1 ;

%% Add a convolutional layer that take as input the pool1 layer
net.addLayer('skip1', ...
     dagnn.Conv('size', [1 1 64 2]), ...
     'x5', 'x49', {'skip1f','skip1b'});%21->3 edited by mR

f = net.getParamIndex('skip1f') ;
net.params(f).value = zeros(1, 1, 64, 2, 'single') ;%'learningRate' need to be modified?
net.params(f).learningRate = 0.01 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('skip1b') ;
net.params(f).value = zeros(1, 1, 2, 'single') ;%21->3 edited by mR
net.params(f).learningRate = 2 ;
net.params(f).weightDecay = 1 ;

%% Add the sumwise layer
net.addLayer('sum4', dagnn.Sum(), {'x48', 'x49'}, 'x50') ;

%% Add deconvolutional layer implementing bilinear interpolation
filters = single(bilinear_u(4, 2, 2)) ;%'crop'modified from 8 to 4 to 2 to 1?
net.addLayer('deconv2x', ...
  dagnn.ConvTranspose('size', size(filters), ...
                      'upsample', 2, ...
                      'crop', 1, ...
                      'numGroups', 2, ...
                      'hasBias', false, ...
                      'opts', net.meta.cudnnOpts), ...
             'x50', 'prediction', 'deconv2xf') ;%21->3 edited by mR

f = net.getParamIndex('deconv2xf') ;
net.params(f).value = filters ;
net.params(f).learningRate = 0 ;
net.params(f).weightDecay = 1 ;

% Make the output of the bilinear interpolator is not discared for
% visualization purposes
net.vars(net.getVarIndex('prediction')).precious = 1 ;

% empirical test
if 0
  figure(100) ; clf ;
  n = numel(net.vars) ;
  for i=1:n
    vl_tightsubplot(n,i) ;
    showRF(net, 'input', net.vars(i).name) ;
    title(sprintf('%s', net.vars(i).name)) ;
    drawnow ;
  end
end
