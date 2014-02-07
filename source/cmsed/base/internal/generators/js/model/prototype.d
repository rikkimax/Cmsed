module cmsed.base.internal.generators.js.model.prototype;
import cmsed.base.internal.generators.js.model.defs;
import dvorm.util;

void handleClassStartPrototype(T, ushort ajaxProtection, T t = newValueOfType!T)(ref GenerateData data) {
    data.saveprop ~= "    save: function() {\n";
    data.saveprop ~= "       var this_ = this;\n";
    data.saveprop ~= "       new Ajax.Request(\"" ~ pathToOOPClasses ~ getTableName!T ~ "/\" + this.";
    
    data.removeprop ~= "    remove: function() {\n";
    data.removeprop ~= "       var this_ = this;\n";
    data.removeprop ~= "       new Ajax.Request(\"" ~ pathToOOPClasses ~ getTableName!T ~ "/\" + this.";
    
    data.findOneArgs ~= getTableName!T ~ ".prototype.findOne = function(";
    data.findOneSet ~= """    var ret;
    new Ajax.Request(\"" ~ pathToOOPClasses ~ getTableName!T ~ "/\" + """;
}

void handleClassEndPrototype(T, ushort ajaxProtection, T t = newValueOfType!T)(ref GenerateData data) {
    data.saveprop ~= """,  {
            method: \"POST\",
            onSuccess: function(event) {
                onSaveOfObject(this_, event);
            },
            onFailure: function(event) {
                onFailudata.retoSaveObject(this_, event);
            }
        });
""";

    data.removeprop ~= """,  {
            method: \"DELETE\",
            onSuccess: function(event) {
                onDeleteOfObject(this_, event);
            },
            onFailure: function(event) {
                onFailureToDeleteObject(this_, event);
            }
        });
""";

    data.saveprop ~= "    },\n";
    data.removeprop ~= "    },\n";
    
    data.props ~= data.saveprop;
    data.props ~= data.removeprop;
        
    data.findOneArgs ~= ") {\n";
    
    data.findOneSet ~= """, {
        method: \"GET\",
        asynchronous: false
    });
    ret = ret.evalReponse();
    return new " ~ getTableName!T ~ "(" ~ data.findOneSetArgs ~ ");\n""";
    data.findOneSet ~= "};\n";
}

void handleFileEndPrototype(T, ushort ajaxProtection, T t = newValueOfType!T)(ref GenerateData data) {
    data.ret ~= data.findOneArgs;
    data.ret ~= data.findOneSet;
}

void handleClassPropertyObjectPropertyPrototype(T, ushort ajaxProtection, string m, string n, // params
                                                T t = newValueOfType!T, U = typeof(mixin("t." ~ m)), V = typeof(mixin("t." ~ m ~ "." ~ n)) // meta info that is needed but not available inside the function
                                                )(ref GenerateData data) {
    string name1 = getNameValue!(T, m);
    string name2 = getNameValue!(U, n);
    
    static if (isAnId!(U, n)) {
        // is first id property?
        if (data.findOneArgs[$-1] == '(') {
            data.findOneArgs ~= name1 ~ "_" ~ name2;
            data.findOneSet ~= name1 ~ "_" ~ name2;
            data.saveprop ~= name1 ~ "_" ~ name2;
            data.removeprop ~= name1 ~ "_" ~ name2;
			data.findOneSetArgs ~= "ret." ~ name1 ~ "_" ~ name2;
        }
    }
}

void handleClassPropertyPrototype(T, ushort ajaxProtection, string m, // params
                                  T t = newValueOfType!T, U = typeof(mixin("t." ~ m)) // meta info that is needed but not available inside the function
                                  )(ref GenerateData data) {
    string name = getNameValue!(T, m);
    if (name == "")
        name = "_";
    
    static if (isAnId!(T, m)) {
        // is first id property?
        if (data.findOneArgs[$-1] == '(') {
            data.findOneArgs ~= name;
            data.findOneSet ~= name;
            data.saveprop ~= name;
            data.removeprop ~= name;
			data.findOneSetArgs ~= "ret." ~ name ~ ", ";
        }
    }
}

void handleClassPropertyRelationshipPrototype(T, ushort ajaxProtection, string m, // params
                                              T t = newValueOfType!T, U = typeof(mixin("t." ~ m)) // meta info that is needed but not available inside the function
                                              )(ref GenerateData data) {
    
}