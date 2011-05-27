function block_out = block_resize(block_in)

global param

block_out = imresize(block_in,[param.feature.block_sz param.feature.block_sz],param.feature.method);