function GetUniqueId(){
    static global_assignment = 0
    var uuid = global_assignment;
    global_assignment++;
    return uuid;
}