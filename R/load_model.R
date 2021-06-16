#' Load resnet18 model.
#'
#' @param 
#' @return Resnet18 model as a torch object.
#'
#' @NoRd
load_model = function(){
	library(torch)
	library(data.table)
	library(glue)
	library(torch)
	conv3x3 = function(in_planes, out_planes, stride=1, groups=1, dilation=1){
	  #"""3x3 convolution with padding"""
	  return(nn_linear(in_planes, out_planes ))
	}


	conv1x1 = function(in_planes, out_planes, stride=1){
	  #"""1x1 convolution"""
	  return(nn_linear(in_planes, out_planes ))
	}

	BasicBlock = nn_module(
	  classname = "BasicBlock",
	  initialize = function(inplanes, planes, stride=1, downsample=NULL, groups=1,
							base_width=64, dilation=1, norm_layer=NULL){
		#cat("Calling basic block initialize!") 
		
		if (is.null(norm_layer)){
		  norm_layer = nn_batch_norm1d
		}
		if ((groups != 1) || (base_width != 64)){
		  message('BasicBlock only supports groups=1 and base_width=64')}
		if (dilation > 1){
		  message("Dilation > 1 not supported in BasicBlock")}
		# Both self.conv1 and self.downsample layers downsample the input when stride != 1
		self$expansion = 1
		self$conv1 = conv3x3(inplanes, planes, stride)
		self$bn1 = norm_layer(planes)
		self$relu = nn_relu(inplace=T)
		self$conv2 = conv3x3(planes, planes)
		self$bn2 = norm_layer(planes)
		self$downsample = downsample
		self$stride = stride
	  },
	  forward = function(x){
		#cat("Calling basic block forward!") 
		identity = torch_clone(x)
		
		out = self$conv1(x)
		out = self$bn1(out)
		out = self$relu(out)
		
		out = self$conv2(out)
		out = self$bn2(out)
		
		#print("1",x_c.shape)
		#print("2,",identity.shape)
		#print(torch.all(x_c == identity))
		if (!is.null(self$downsample)){
		  identity = self$downsample(x)}
		
		out = torch_add(out,identity)
		out = self$relu(out)
		
		
		return(out)
	  }
	)

	Bottleneck = nn_module(
	  classname = "Bottleneck",
	  initialize = function(inplanes, planes, stride=1, downsample=NULL, groups=1,
							base_width=64, dilation=1, norm_layer=NULL){
		if (is.null(norm_layer)){
		  norm_layer = nn_batch_norm1d}
		width = as.integer(planes * (base_width / 64.)) * groups
		# Both self.conv2 and self.downsample layers downsample the input when stride != 1
		self$expansion = 4
		self$conv1 = conv1x1(inplanes, width)
		self$bn1 = norm_layer(width)
		self$conv2 = conv3x3(width, width, stride, groups, dilation)
		self$bn2 = norm_layer(width)
		self$conv3 = conv1x1(width, planes * self$expansion)
		self$bn3 = norm_layer(planes * self$expansion)
		self$relu = nn_relu(inplace=T)
		self$downsample = downsample
		self$stride = stride
	  },
	  forward = function(x){
		identity = torch_clone(x)
		
		out = self$conv1(x)
		out = self$bn1(out)
		out = self$relu(out)
		
		out = self$conv2(out)
		out = self$bn2(out)
		out = self$relu(out)
		
		out = self$conv3(out)
		out = self$bn3(out)
		
		if (!is.null(self$downsample)){
		  identity = self$downsample(x)}
		
		out = torch_add(out, identity)
		out = self$relu(out)
		
		return(out)
	  }
	)

	ResNet_fc = nn_module(
	  classname = "ResNet_fc",
	  initialize = function(input_features, layers, num_classes, zero_init_residual=F,
							groups=1, width_per_group=64, replace_stride_with_dilation=NULL,
							norm_layer=NULL) {
		self$block_expansion = 1
		# if bottle neck: self.bottle_expansion = 4
		block = BasicBlock
		if (is.null(norm_layer)){
		  norm_layer = nn_batch_norm1d}
		self$norm_layer_ = norm_layer
		
		self$inplanes = 64 #
		self$dilation = 1
		
		self$make_layer_ = function(block, planes, blocks, stride=1, dilate=F){
		  norm_layer = self$norm_layer_
		  downsample = NULL
		  
		  previous_dilation = self$dilation
		  if (dilate){
			self$dilation = torch_matmul(self$dilation, stride)
			stride = 1
		  }
		  
		  if ((stride != 1) || (self$inplanes != (planes * self$block_expansion))){
			downsample = nn_sequential(
			  conv1x1(self$inplanes, planes * self$block_expansion, stride),
			  self$norm_layer_(planes * self$block_expansion)
			)
		  }
		  
		  #layers = base::c()
		  layer1 = block(self$inplanes, planes, stride, downsample, self$groups,
						 self$base_width, previous_dilation, norm_layer)
		  self$inplanes = planes * self$block_expansion
		  
		  layer2 = block(self$inplanes, planes, groups=self$groups,
						 base_width=self$base_width, dilation=self$dilation,
						 norm_layer=norm_layer)
		  
		  return (nn_sequential(layer1,layer2))
		}
		# can not do nn.sequential([]), so it froozed at 2 layers now. -? 0614.
		
		if (is.null(replace_stride_with_dilation)){
		  # each element in the tuple indicates if we should replace
		  # the 2x2 stride with a dilated convolution instead
		  replace_stride_with_dilation = base::c(F, F, F)}
		if (length(replace_stride_with_dilation) != 3){
		  message(glue("replace_stride_with_dilation should be None or a 3-element tuple, got {replace_stride_with_dilation}"))}
		self$groups = groups
		self$base_width = width_per_group
		self$conv1 = nn_linear(input_features, self$inplanes)
		self$bn1 = norm_layer(self$inplanes)
		self$relu = nn_relu(inplace=T)
		#self.maxpool = nn.MaxPool2d(kernel_size=3, stride=2, padding=1)
		self$layer1 = self$make_layer_(block, 64, layers[1])
		
		self$layer2 = self$make_layer_(block, 128, layers[2], stride=2,
									   dilate=replace_stride_with_dilation[1])
		self$layer3 = self$make_layer_(block, 256, layers[3], stride=2,
									   dilate=replace_stride_with_dilation[2])
		self$layer4 = self$make_layer_(block, 512, layers[4], stride=2,
									   dilate=replace_stride_with_dilation[3])
		#self.avgpool = nn.AdaptiveAvgPool2d((1, 1))
		self$fc = nn_linear(512 * self$block_expansion, num_classes)
		
		# initialization -> remove (0614)
		#for m in self.modules():
		#if isinstance(m, nn.Conv1d):
		#    nn.init.kaiming_normal_(m.weight, mode='fan_out', nonlinearity='relu')
		#elif isinstance(m, (nn_batch_norm1d, nn.GroupNorm)):
		#    nn.init.constant_(m.weight, 1)
		#    nn.init.constant_(m.bias, 0)
		
		# Zero-initialize the last BN in each residual branch,
		# so that the residual branch starts with zeros, and each residual block behaves like an identity.
		# This improves the model by 0.2~0.3% according to https://arxiv.org/abs/1706.02677
		#if zero_init_residual:
		#    for m in self.modules():
		#        if isinstance(m, Bottleneck):
		#            nn.init.constant_(m.bn3.weight, 0)
		#        elif isinstance(m, BasicBlock):
		#            nn.init.constant_(m.bn2.weight, 0)
		#print("initalizing resnet!")
		
	  },
	  
	  forward = function(x){
		
		#print("forward resnet")
		x = self$conv1(x)
		x = self$bn1(x)
		x = self$relu(x)
		#x = self.maxpool(x)
		x = self$layer1(x)
		x = self$layer2(x)
		x = self$layer3(x)
		x = self$layer4(x)
		
		#x = self.avgpool(x)
		#x = torch_flatten(x, 1)
		x = self$fc(x)
		
		return(x)
	  }
	)
	load(system.file("data/state_dic.rda",package = "brammer"))
	for (i_name in names(state_dic)){
	  dat = state_dic[[i_name]]
	  dat = torch_tensor(as.matrix(dat))
	  dat = torch_squeeze(dat)
	  state_dic[[i_name]] = dat
	  
	}
	Resnet18_fc =  ResNet_fc(2616, base::c(2, 2, 2, 2),2)
	# eval
	Resnet18_fc$load_state_dict(state_dic)
	Resnet18_fc$eval()
	return(Resnet18_fc)
}