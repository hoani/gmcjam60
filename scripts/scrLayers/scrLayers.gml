#macro LAYER_BACK "back"
#macro LAYER_WORLD "world"
#macro LAYER_UI "ui"

function InstanceCreateBack(_x, _y, _obj, _struct={}){
	return instance_create_layer(_x, _y, LAYER_BACK, _obj, _struct)
}

function InstanceCreate(_x, _y, _obj, _struct={}){
	return instance_create_layer(_x, _y, LAYER_WORLD, _obj, _struct)
}

function InstanceCreateUi(_x, _y, _obj, _struct={}){
	return instance_create_layer(_x, _y, LAYER_UI, _obj, _struct)
}