module test.trestful;
import cmsed.base.restful;
import cmsed.base.routing;
import cmsed.base.udas;
import dvorm;

class SomeDataModel {
    @dbId
    string key;
    string value;

    mixin OrmModel!SomeDataModel;
}

mixin RestfulRoute!(RestfulProtection.All, SomeDataModel);