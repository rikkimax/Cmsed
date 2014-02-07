module cmsed.base.internal.generators.js.model.prototype;
import cmsed.base.internal.generators.js.model.defs;
import dvorm.util;

void handleClassStartPrototype(T, ushort ajaxProtection, T t = newValueOfType!T)(ref string ret, ref string constructorArgs, ref string constructorSet, ref string props, ref string saveprop, ref string removeprop, ref string findOneArgs, ref string findOneSet, ref string findOneSetArgs) {
    saveprop ~= "    save: function() {\n";
    saveprop ~= "       var this_ = this;\n";
    saveprop ~= "       new Ajax.Request(\"" ~ pathToOOPClasses ~ getTableName!T ~ "/\" + this.";
    
    removeprop ~= "    remove: function() {\n";
    removeprop ~= "       var this_ = this;\n";
    removeprop ~= "       new Ajax.Request(\"" ~ pathToOOPClasses ~ getTableName!T ~ "/\" + this.";
    
    findOneArgs ~= getTableName!T ~ ".prototype.findOne = function(";
    findOneSet ~= """    var ret;
    new Ajax.Request(\"" ~ pathToOOPClasses ~ getTableName!T ~ "/\" + """;
}

void handleClassEndPrototype(T, ushort ajaxProtection, T t = newValueOfType!T)(ref string ret, ref string constructorArgs, ref string constructorSet, ref string props, ref string saveprop, ref string removeprop, ref string findOneArgs, ref string findOneSet, ref string findOneSetArgs) {
    saveprop ~= """,  {
            method: \"POST\",
            onSuccess: function(event) {
                onSaveOfObject(this_, event);
            },
            onFailure: function(event) {
                onFailureToSaveObject(this_, event);
            }
        });
""";

    removeprop ~= """,  {
            method: \"DELETE\",
            onSuccess: function(event) {
                onDeleteOfObject(this_, event);
            },
            onFailure: function(event) {
                onFailureToDeleteObject(this_, event);
            }
        });
""";

    saveprop ~= "    },\n";
    removeprop ~= "    },\n";
    
    props ~= saveprop;
    props ~= removeprop;
        
    findOneArgs ~= ") {\n";
    
    findOneSet ~= """, {
        method: \"GET\",
        asynchronous: false
    });
    ret = ret.evalReponse();
    return new " ~ getTableName!T ~ "(" ~ findOneSetArgs ~ ");\n""";
    findOneSet ~= "};\n";
}

void handleFileEndPrototype(T, ushort ajaxProtection, T t = newValueOfType!T)(ref string ret, ref string constructorArgs, ref string constructorSet, ref string props, ref string saveprop, ref string removeprop, ref string findOneArgs, ref string findOneSet, ref string findOneSetArgs) {
    ret ~= findOneArgs;
    ret ~= findOneSet;
}

void handleClassPropertyObjectPropertyPrototype(T, ushort ajaxProtection, string m, string n, // params
                                                T t = newValueOfType!T, U = typeof(mixin("t." ~ m)), V = typeof(mixin("t." ~ m ~ "." ~ n)) // meta info that is needed but not available inside the function
                                                )(ref string ret, ref string constructorArgs, ref string constructorSet, ref string props, ref string saveprop, ref string removeprop, ref string findOneArgs, ref string findOneSet, ref string findOneSetArgs) {
    string name1 = getNameValue!(T, m);
    string name2 = getNameValue!(U, n);
    
    static if (isAnId!(U, n)) {
        // is first id property?
        if (findOneArgs[$-1] == '(') {
            findOneArgs ~= name1 ~ "_" ~ name2;
            findOneSet ~= name1 ~ "_" ~ name2;
            saveprop ~= name1 ~ "_" ~ name2;
            removeprop ~= name1 ~ "_" ~ name2;
			findOneSetArgs ~= "ret." ~ name1 ~ "_" ~ name2;
        }
    }
}

void handleClassPropertyPrototype(T, ushort ajaxProtection, string m, // params
                                  T t = newValueOfType!T, U = typeof(mixin("t." ~ m)) // meta info that is needed but not available inside the function
                                  )(ref string ret, ref string constructorArgs, ref string constructorSet, ref string props, ref string saveprop, ref string removeprop, ref string findOneArgs, ref string findOneSet, ref string findOneSetArgs) {
    string name = getNameValue!(T, m);
    if (name == "")
        name = "_";
    
    static if (isAnId!(T, m)) {
        // is first id property?
        if (findOneArgs[$-1] == '(') {
            findOneArgs ~= name;
            findOneSet ~= name;
            saveprop ~= name;
            removeprop ~= name;
			findOneSetArgs ~= "ret." ~ name ~ ", ";
        }
    }
}

void handleClassPropertyRelationshipPrototype(T, ushort ajaxProtection, string m, // params
                                              T t = newValueOfType!T, U = typeof(mixin("t." ~ m)) // meta info that is needed but not available inside the function
                                              )(ref string ret, ref string constructorArgs, ref string constructorSet, ref string props, ref string saveprop, ref string removeprop, ref string findOneArgs, ref string findOneSet, ref string findOneSetArgs) {
    
}