module cmsed.base.internal.models.defs;
public import cmsed.base.internal.models.session;
public import cmsed.base.internal.models.nodes;

shared static this() {
    import cmsed.base.registration.autoregister;
    autoRegister!__MODULE__;
}