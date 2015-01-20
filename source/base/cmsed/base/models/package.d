module cmsed.base.models;
import cmsed.base.registration.autoregister;

public import cmsed.base.models.systemsettings;
public import cmsed.base.models.pagetemplate;

shared static this() {
	autoRegister!__MODULE__;
}