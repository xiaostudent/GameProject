
DEBUG = 2                        -- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
CC_USE_FRAMEWORK = true          -- use framework, will disable all deprecated API, false - use legacy API
CC_SHOW_FPS = true               -- show FPS on screen
CC_DISABLE_GLOBAL = false         -- disable create unexpected global variable
CC_DEFAULT_FONT_LABEL_SIZE= 26
CC_DEFAULT_FONT_PATH = "res/font/VonwaonBitmap-16px.ttf"

-- for module display
CC_DESIGN_RESOLUTION = {
    width = 960,
    height = 640,
    autoscale = "FIXED_HEIGHT",
    callback = function(framesize)
        local ratio = framesize.width / framesize.height
        if ratio <= 1.34 then
            -- iPad 768*1024(1536*2048) is 4:3 screen
            return {autoscale = "FIXED_WIDTH"}
        end
    end
}

spriteFrameCache=cc.SpriteFrameCache:getInstance()

DEBUG_MEM=true
local  needUpdate = true


if DEBUG_MEM then
    local function showMemoryUsage()
        if printInfo then
            printInfo(string.format("LUA VM MEMORY USED: %0.2f KB", collectgarbage("count")))
            printInfo(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
            printInfo("---------------------------------------------------")
        end
    end
    cc.Director:getInstance():getScheduler():scheduleScriptFunc(showMemoryUsage,120.0, false)
end

cc.FileUtils:getInstance():setPopupNotify(false)
print("jit的版本号为",jit.version,(jit.version >= "LuaJIT 2.1"),jit.arch)
cc.FileUtils:getInstance():addSearchPath(cc.FileUtils:getInstance():getWritablePath().."Resources/")
cc.FileUtils:getInstance():addSearchPath(cc.FileUtils:getInstance():getWritablePath().."Resources/res")
loadChunksFromZIP("core32.hjx")
loadChunksFromZIP("update32.hjx")
require "core.init"
require("socket")

local function loadLuaZip( ... )
	loadChunksFromZIP("cocos32.hjx")
    loadChunksFromZIP("config32.hjx")
    loadChunksFromZIP("app32.hjx")
    require "cocos.init"
    require("app.config.init")
    cc.disable_global()   --延迟屏蔽
    require("app.widget.common.init")
    require("app.MainApp")
end


local function enterGame( ... )
    -- body
    if GameScene:isRunning() then
        loadLuaZip()
    else
        local function onNodeEvent(event)
            if event == "enter" then
                loadLuaZip()
            elseif event == "exit" then

            end
        end
        GameScene:registerScriptHandler(onNodeEvent)
    end
end


local function main()
    if needUpdate then
        require("update.UpdateController")
        GameController:show("update")
        require("update")(function ( ... )
            -- body
            enterGame()
        end)
    else
        enterGame()
    end
end


function __G__TRACKBACK__(errorMessage)
	local erroLog = "----------------------------------------";
    erroLog = erroLog .. "\nLUA ERROR: " .. tostring(errorMessage) .. "\n"
    erroLog = erroLog .. "\n" .. debug.traceback("", 2);
    erroLog = erroLog .. "\n----------------------------------------";
    print(erroLog)

    showTips({title="代码错误",textColor={ r = 255, g = 0, b = 0 },text=erroLog})

    local mode = "a+b"
    local path=cc.FileUtils:getInstance():getWritablePath() .. "/error.log"
    local file, msg = io.open(path, mode)
    if file then
        if file:write(erroLog) == nil then print("写入错误") end
        io.close(file)
    end
end


local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end





