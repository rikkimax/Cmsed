module cmsed.lua.internal.handler;
import luad.all;
import vibe.d : TaskLocal;

private TaskLocal!(InitData!LuaState) luaState;
private TaskLocal!bool initialised;

LuaState getState() {
    if (!initialised.storage()) {
        import cmsed.lua.internal.configure.datamodel;
        import skeleton.syntax.luasyn;

        initialised.storage() = true;

        luaState = TaskLocal!(InitData!LuaState)(InitData!LuaState(new LuaState));
        luaState.openLibs();
        luaState.configureLuaWithDependencies();

        // TODO: what happens in production?
        // shouldn't this be cached? or is a file

        configureAllDataModels(luaState);
        // caches
        // routes modules (includes misc)

        luaState.doString("""
function echo(...)
    local out = \"\"
    for i,v in ipairs(arg) do
        out = out .. tostring(v)
    end
    echo_(out)
end
""");
    }

    luaState.doString("""
-- http://lua-users.org/wiki/SimpleStack

-- Stack Table
-- Uses a table as stack, use <table>:push(value) and <table>:pop()
-- Lua 5.1 compatible

-- GLOBAL
Stack = {}

-- Create a Table with stack functions
function Stack:Create()

  -- stack table
  local t = {}
  -- entry table
  t._et = {}

  -- push a value on to the stack
  function t:push(...)
    if ... then
      local targs = {...}
      -- add values
      for _,v in ipairs(targs) do
        table.insert(self._et, v)
      end
    end
  end

  -- pop a value from the stack
  function t:pop(num)

    -- get num values from stack
    local num = num or 1

    -- return table
    local entries = {}

    -- get values into entries
    for i = 1, num do
      -- get last entry
      if #self._et ~= 0 then
        table.insert(entries, self._et[#self._et])
        -- remove last value
        table.remove(self._et)
      else
        break
      end
    end
    -- return unpacked entries
    return unpack(entries)
  end

  -- get entries
  function t:size()
    return #self._et
  end

  -- list values
  function t:list()
    for i,v in pairs(self._et) do
      print(i, v)
    end
  end
  return t
end

-- CHILLCODE™
""");

    luaState.doString("""
I_P_INCLUDE_P_I = Stack:Create()
I_P_INCLUDE_TEXT_P_I = Stack:Create()

I_P_PEEK_NEXT_P_I = Stack:Create()
I_P_CONSUME_NEXT_P_I = Stack:Create()

-- in / out for include instances

function include_backups_in_()
    I_P_INCLUDE_P_I:push(include_)
    I_P_INCLUDE_TEXT_P_I:push(include_text_)

    I_P_PEEK_NEXT_P_I:push(peekNext_)
    I_P_CONSUME_NEXT_P_I:push(consumeNext_)
end

function include_backups_out_()
    include_ = I_P_INCLUDE_P_I:pop()
    include_text_ = I_P_INCLUDE_TEXT_P_I:pop()

    peekNext_ = I_P_PEEK_NEXT_P_I:pop()
    consumeNext_ = I_P_CONSUME_NEXT_P_I:pop()
end

-- wrappers around D's implementation

function include(text)
    include_(text)
    include_backups_out_()
end

function include_text(text)
    include_text_(text)
    include_backups_out_()
end

function peekNext()
    local type, value = peekNext_()
    if (type == '' and value == '') then
        return nil, nil
    end
   
    return type, value
end

function consumeNext()
    local type, value = consumeNext_()
    if (type == '' and value == '') then
        return nil, nil
    end
   
    return type, value
end

function consumeNextText()
    local type, value = consumeNext()
    return value
end
""");

    return luaState;
}

private {
    struct InitData(T) {
        T value;

        alias value this;
    }
}