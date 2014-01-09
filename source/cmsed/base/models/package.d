module cmsed.base.models;
import cmsed.base.registration.model;

public import cmsed.base.models.session;
public import cmsed.base.models.systemsettings;
public import cmsed.base.models.widgitusage;

shared static this() {
	registerModel!SessionModel();
	registerModel!SystemSettingModel();
	registerModel!WidgitUsageModel();
}