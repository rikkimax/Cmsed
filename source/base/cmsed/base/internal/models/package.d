module cmsed.base.internal.models;
import cmsed.base.registration.model;
import cmsed.base.registration.onload;

public import cmsed.base.internal.models.session;
public import cmsed.base.internal.models.nodes;

shared static this() {
	registerModel!SessionModel();
	registerModel!SystemNodesModel();
	registerModel!SystemNodeIpModel();
}