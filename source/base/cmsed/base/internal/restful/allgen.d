module cmsed.base.internal.restful.allgen;

pure string restAllCheck(ushort protection, TYPES...)() {
    import cmsed.base.internal.restful.get;
    import cmsed.base.internal.restful.remove;
    import cmsed.base.internal.restful.modify;
    import cmsed.base.internal.restful.create;
    import cmsed.base.internal.restful.query;
    import cmsed.base.restful;
    
    string ret;
    foreach(C; TYPES) {
        static if ((protection & RestfulProtection.View) != 0) {
            ret ~= getRestfulData!C();
            ret ~= queryRestfulData!C();
        }
        
        static if ((protection & RestfulProtection.Create) != 0) {
            ret ~= createRestfulData!C();
        }
        
        static if ((protection & RestfulProtection.Update) != 0) {
            ret ~= modifyRestfulData!C();
        }
        
        static if ((protection & RestfulProtection.Delete) != 0) {
            ret ~= removeRestfulData!C();
        }
    }
    return ret;
}