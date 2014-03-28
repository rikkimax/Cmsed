module cmsed.base.models;
import cmsed.base.registration.model;

public import cmsed.base.models.systemsettings;
public import cmsed.base.models.widgetusage;

shared static this() {
	registerModel!SystemSettingModel();
	registerModel!WidgetUsageModel();
}