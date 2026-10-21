function SetPlaGravity(g){
    global.platGravity = g
} 


function PlaGravity(){
     if !variable_global_exists("platGravity") {
        global.platGravity = 1/16;
    }
    return global.platGravity;
}   
