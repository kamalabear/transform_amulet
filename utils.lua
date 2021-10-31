utils = {}

-- Convenience method for recursively logging the attributes of any object/variable
utils.log_attributes = function(thing, name)
    minetest.log("*** " .. name .. " ***")
    local thing_type = type(thing)

    -- if thing isn't a table or userdata, just log the value
    if
        thing_type == "boolean" or thing_type == "nil" or thing_type == "number" or thing_type == "string" or
            thing_type == "thread"
     then
        minetest.log(name .. " is a " .. thing_type .. " with a value of " .. tostring(thing))
        return
    elseif thing_type == "userdata" then
        thing = getmetatable(thing)
    elseif thing_type == "function" then
        local nparams = debug.getinfo(thing).nparams
        if nparams > 0 then
            minetest.log(name .. " is a function that requires " .. nparams .. " arguments")
        else
            utils.log_attributes(thing(), name)
            return
        end
    end

    for i, v in pairs(thing) do
        if type(v) == "string" then
            minetest.log(i .. ": " .. v)
        elseif type(v) == "table" then
            minetest.log(i .. ": [")
            utils.log_attributes(v, i)
            minetest.log("]")
        elseif type(v) == "userdata" then
            minetest.log(i .. ": [")
            utils.log_attributes(getmetatable(v), i)
            minetest.log("]")
        elseif type(v) == "function" then
            minetest.log(i .. ": " .. tostring(v) .. "(" .. debug.getinfo(v).nparams .. ")")
        else
            minetest.log(i .. ": " .. tostring(v))
        end
    end
    minetest.log("*** end " .. name .. " ***")
end
