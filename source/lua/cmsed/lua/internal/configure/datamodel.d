module cmsed.lua.internal.configure.datamodel;
import luad.all;
import cmsed.base.registration.model : isDataModel;

private __gshared {
    void delegate(LuaState)[] configModels;
}

void configureDataModel(T)() if (isDataModel!T) {
    void configure(LuaState state) {
        // TODO: stuff here
    }
    
    configModels ~= &configure;
}

void configureAllDataModels(LuaState state) {
    foreach(func; configModels) {
        func(state);
    }
}