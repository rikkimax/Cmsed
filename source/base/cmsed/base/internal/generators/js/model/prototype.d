module cmsed.base.internal.generators.js.model.prototype;
import cmsed.base.internal.generators.js.model.defs;
import dvorm.util;

void handleClassStartPrototype(T, ushort ajaxProtection, T t = newValueOfType!T)(ref GenerateData data) {
	data.saveprop ~= "    save: function() {\n";
	data.saveprop ~= "       var this_ = this;\n";
	data.saveprop ~= "       new Ajax.Request(\"" ~ pathToRestfulRoute ~ getTableName!T ~ "/\" + this.";
	
	data.savepropParams ~= "            parameters: {\n";
	
	data.removeprop ~= "    remove: function() {\n";
	data.removeprop ~= "       var this_ = this;\n";
	data.removeprop ~= "       new Ajax.Request(\"" ~ pathToRestfulRoute ~ getTableName!T ~ "/\" + this.";
	
	data.findOneArgs ~= getTableName!T ~ ".prototype.findOne = function(";
	data.findOneSet ~= """    var ret = new Ajax.Request(\"" ~ pathToRestfulRoute ~ getTableName!T ~ "/\" + """;
	
	data.queryCreator ~= """
Books3.prototype.query = function() {
    return {
        props: {""";
}

void handleClassEndPrototype(T, ushort ajaxProtection, T t = newValueOfType!T)(ref GenerateData data) {
	if (data.savepropParams[$-2] == ',') {
		data.savepropParams.length -= 2;
		data.savepropParams ~= '\n';
	}
	data.savepropParams ~= "            },";
	data.saveprop ~= """,  {
            method: \"POST\",
" ~ data.savepropParams ~ "
            onSuccess: function(event) {
                onSaveOfObject(this_, event);
            },
            onFailure: function(event) {
                onFailureToSaveObject(this_, event);
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
    ret = ret.responseJSON();
    return new " ~ getTableName!T ~ "(" ~ data.findOneSetArgs ~ ");\n""";
	data.findOneSet ~= "};\n";
	
	if (data.queryCreator[$-1] == ',')
		data.queryCreator.length--;
	
	data.queryCreator ~= """
        },
        offset: undefined,
        maxAmount: undefined,
        find: function () {
            this_ = this;
            var ret = new Ajax.Request(\"" ~ pathToRestfulRoute ~ getTableName!T ~ "/\", {
                method: \"POST\",
                parameters: {
" ~ data.queryParameters ~ "                    __offset: this_.offset,
                    __maxAmount: this_.maxAmount
                },
                onSuccess: function (event) {

                },
                onFailure: function (event) {

                }
            });
            ret = ret.responseJSON();
        }
    };
};
""";
}

void handleFileEndPrototype(T, ushort ajaxProtection, T t = newValueOfType!T)(ref GenerateData data) {
	data.ret ~= data.findOneArgs;
	data.ret ~= data.findOneSet;
	data.ret ~= data.queryCreator;
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
			data.savepropParams ~= "                " ~ name1 ~ "_" ~ name2 ~ ": this_." ~ name1 ~ "_" ~ name2 ~ ",\n";
		}
	}
	
	foreach(action; ["eq", "neq", "lt", "lte", "mt", "mte", "like"]) {
		data.queryParameters ~= "                    " ~ name1 ~ "_" ~ name2 ~ "_" ~ action ~ ": this_.props." ~ name1 ~ "_" ~ name2 ~ "_" ~ action ~ ",\n";
		data.queryCreator ~= "\n            " ~ name1 ~ "_" ~ name2 ~ "_" ~ action ~ ": undefined,";
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
			data.findOneSetArgs ~= "resht." ~ name ~ ", ";
			data.savepropParams ~= "                " ~ name ~ ": this_." ~ name ~ ",\n";
		}
	}
	
	foreach(action; ["eq", "neq", "lt", "lte", "mt", "mte", "like"]) {
		data.queryParameters ~= "                    " ~ name ~ "_" ~ action ~ ": this_.props." ~ name ~ "_" ~ action ~ ",\n";
		data.queryCreator ~= "\n            " ~ name ~ "_" ~ action ~ ": undefined,";
	}
}

void handleClassPropertyRelationshipPrototype(T, ushort ajaxProtection, string m, // params
                                              T t = newValueOfType!T, U = typeof(mixin("t." ~ m)) // meta info that is needed but not available inside the function
                                              )(ref GenerateData data) {
	
}