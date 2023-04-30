local memory = require("memory")
local ffi = require("ffi")
local events = require("events")

-- disable mouse control
function hookControl()
    local controlMemoryAddress = memory.at("8B 0D ? ? ? ? 51 FF 50 ? 89 45 ? EB"):add(2):readOffset():readOffset()
        :readOffset()
        :add(36)
        :readOffset()
    local hook
    hook = controlMemoryAddress:hook("int (__stdcall*)(int, int, int*)",
        function(a, b, c)
            local res = hook.orig(a, b, c)
            if b == 16 and c ~= nil then
                c[0] = 0
            end
            return res
        end)
end

-- validate game state
if game.isGameLoaded() then
    hookControl()
else
    events.on("gameLoaded", hookControl)
end


ffi.cdef [[
    int SetCursorPos(int, int)
]]

-- disable set cursor pos
local setCursorPosMemoryAddress = memory.at(tonumber(ffi.cast("intptr_t", ffi.C.SetCursorPos)) --[[@as number]])
local cursorPosHook
cursorPosHook = setCursorPosMemoryAddress:hook("int __stdcall (*)(int, int)",
    function(a, b)
        return 0;
    end)

-- disable hide cursor
local hideCursorMemoryAddress = memory.at("55 8B EC 51 0F B6 45")
local hideCursorHook
hideCursorHook = hideCursorMemoryAddress:hook("int __cdecl (*)(char )",
    function(a1)
        return 0;
    end)
