module cmsed.overrides.registration.autoregister;

void autoRegister(string DFILE, string SYMBL)() {
    mixin("static import " ~ DFILE ~ ";");
    mixin("alias symbl = " ~ DFILE ~ "." ~ SYMBL ~ ";");

    //pragma(msg, "OVERRIDE: " ~ DFILE ~ "." ~ SYMBL);
}