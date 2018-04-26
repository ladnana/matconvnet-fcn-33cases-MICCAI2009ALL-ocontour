function net = fcnInitializeModel4s(net)
%FCNINITIALIZEMODEL8S Initialize the FCN-4S model from FCN-8S

%% Remove the last layer
net.removeLayer('deconv8') ;

%% Add the first deconv layer
filters = single(bilinear_u(4, 1, 2)) ;%not sure that do 'crop' need to be modified ?
net.addLayer('deconv3bis', ...
  dagnn.ConvTranspose('size', size(filters), ...
                      'upsample', 2, ...
                      'crop', 1, ...
                      'hasBias', false), ...
             'x44', 'x45', 'deconv3bisf') ;
f = net.getParamIndex('deconv3bisf') ;
net.params(f).value = filters ;
net.params(f).learningRate = 0 ;
net.params(f).weightDecay = 1 ;

%% Add a convolutional layer that take as input the pool2 layer
net.addLayer('skip2', ...
     dagnn.Conv('size', [1 1 128 2]), ...
     'x10', 'x46', {'skip2f','skip2b'});%21->3 edited by mR

f = net.getParamIndex('skip2f') ;
net.params(f).value = zeros(1, 1, 128, 2, 'single') ;%'learningRate' need to be modified?
net.params(f).learningRate = 0.01 ;
net.params(f).weightDecay = 1 ;

f = net.getParamIndex('skip2b') ;
net.params(f).value = zeros(1, 1, 2, 'single') ;%21->3 edited by mR
net.params(f).learningRate = 2 ;
net.params(f).weightDecay = 1 ;

%% Add the sumwise layer
net.addLayer('sum3', dagnn.Sum(), {'x45', 'x46'}, 'x47') ;

%% Add deconvolutional layer implementing bilinear interpolation
filters = single(bilinear_u(8, 2, 2)) ;%'crop'modified from 8 to 4 to 2?
net.addLayer('deconv4', ...
  dagnn.ConvTranspose('size', size(filters), ...
                      'upsample', 4, ...
                      'crop', 2, ...
                      'numGroups', 2, ...
                      'hasBias', false, ...
                      'opts', net.meta.cudnnOpts), ...
             'x47', 'prediction', 'deconv4f') ;%21->3 edited by mR

f = net.getParamIndex('deconv4f') ;
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
