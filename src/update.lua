require("core.util.json")
local Array=require("core.ADT.Array")
local functions=require("core.util.functions")
local Http=require("core.http.Http")
local File=require("core.util.File")
local FileUtils=cc.FileUtils:getInstance()
local writablePath=cc.FileUtils:getInstance():getWritablePath()
local versionPath=writablePath.."/version.manifest"
local M={}
M.packageUrl=""
M.enterGame=nil
LoadList=Array:ctor()
moveFileList=Array:ctor()

local function getPackageUrl()
	-- body
	return M.packageUrl
end


local function HttpLoad(_url,func)
	Http.request(_url,function ( data,url )
	    -- body
	    if func then func( data,url ) end
	end,function (status,url)
		-- body
		print("http:"..url .."  error!")
		showTips("游戏更新失败！请查看网络连接")
	end,function ()
		-- body
	end,function ()
		print("http:"..url .."  time out!")
		showTips("游戏更新失败！请查看网络连接")
	end)
end

--
local function moveToWritablePath( ... )
	-- body
	if not FileUtils:isFileExist(versionPath)  then
		local path=FileUtils:fullPathForFilename("version.manifest")
		local versionData=FileUtils:getStringFromFile(path) --android apk为压缩包，所以要用内置的读取，不能用os.read
		File.write(versionPath,versionData)
	else
		print("版本version.manifest存在")
	end
end

local function loadVersionMainfest( path )
	-- body
	local versionData=File.read(path)
	versionData=string.gsub(versionData,"\\","")
	return json.decode(versionData)
end

local function loadRemoteFile( path ,func )
	if not FileUtils:isFileExist(writablePath..path)  then
		HttpLoad(getPackageUrl()..path,function ( data,url )
		    -- body
		    File.write(writablePath..path,data)
		    if func then func() end
		end)
	else
		print(writablePath..path.."存在")
		if func then func() end
	end
end

local function loadGameVerFest( vers ,func)
	-- body
	if not FileUtils:isDirectoryExist(writablePath.."ver_files") then FileUtils:createDirectory(writablePath.."ver_files") end
	local path="ver_files/ver_diff"..vers..".manifest"
	loadRemoteFile(path,func)
end

local function loadGameMainFest( vers ,func)
	-- body
	if not FileUtils:isDirectoryExist(writablePath.."version") then FileUtils:createDirectory(writablePath.."version") end
	local path="version/"..vers..".manifest"
	loadRemoteFile(path,func)
end

local function createDirectory( filePath )
	-- body
	local arr=functions.split(filePath,"/")
	local path=writablePath

	for i,v in ipairs(arr) do
		if i<#arr then
			path=path.."/"..v
			if not FileUtils:isDirectoryExist(path) then FileUtils:createDirectory(path) end
		end
	end
end


local function checkFile( data, path )
	-- body
	local size=File.size(path)
	if not size then   --android 文件大小为空
		size=cc.FileUtils:getInstance():getFileSize(path)
	end
	if data.size==size then
		return true
	end
	return false
end

local function loadGameFile(_data ,func)
	-- body
	local filePath=_data.path
	local version=_data.version
	createDirectory("tmp/"..filePath)
	local check=function ()
	    if checkFile(_data,writablePath.."tmp/"..filePath) then
	    	print("文件校验成功："..writablePath.."tmp/"..filePath)
	    	moveFileList:push({src=writablePath.."tmp/"..filePath,des=writablePath.."/"..filePath,filePath=filePath})
	    	if func then func() end
	    else
	    	_data.loadTime=_data.loadTime+1
	    	print("文件校验失败："..writablePath.."tmp/"..filePath)
	    	if _data.loadTime>=3 then
	    		print("更新失败！")
	    		return
	    	else
	    		File.removeFile(writablePath.."tmp/"..filePath)
	    		loadGameFile(_data ,func)
	    	end
	    end
	end
	if  not FileUtils:isFileExist(writablePath.."tmp/"..filePath)  then
		print("下载："..writablePath.."tmp/"..filePath)
		HttpLoad(getPackageUrl().."ver_files/"..version.."/"..filePath,function ( data,url )
		    -- body
		    File.write(writablePath.."tmp/"..filePath,data)
		    check()
		end)
	else
		print(writablePath.."tmp/"..filePath.."存在")
 		check()
	end
end

local function moveFile( currVersion,nextVersion )
	-- body
	if  moveFileList:length()>0 then
		local data=moveFileList:shift()
		createDirectory(data.filePath)
		local fileData=File.read(data.src,"rb")
		File.write(data.des,fileData)
		moveFile(currVersion,nextVersion)
	else
		print("热更文件移动完成！")
		File.removeDirectory(writablePath.."tmp")
		File.removeDirectory(writablePath.."ver_files")
		File.removeDirectory(writablePath.."version")
		local t=loadVersionMainfest(versionPath)
		t.version=nextVersion
		table.insert(t.versionsList,nextVersion)
		File.write(versionPath,json.encode(t))
		M.update(M.enterGame)
	end
end


local function loadFile(currVersion,nextVersion)
	-- body
	if LoadList:length()>0 then
		local data=LoadList:shift()
		loadGameFile(data,function ( ... )
			-- body
			Event:emit("update_module",{cmd="update_loadFile",data=data})
			loadFile(currVersion,nextVersion)
		end)
	else
		print("热更文件下载完成")
		loadGameMainFest(nextVersion,function ( ... )
			-- body
			Event:emit("update_module",{cmd="update_endLoad"})
			print("对比版本md5:",currVersion,nextVersion)
			local currVerData=loadVersionMainfest(writablePath.."version/"..currVersion..".manifest")
			local nextVerData=loadVersionMainfest(writablePath.."version/"..nextVersion..".manifest")
			for k,v in pairs(currVerData.assets) do
				if not nextVerData.assets[k] then   --删除文件
					if File.isFileExist(writablePath..k) then
						print("删除文件："..writablePath..k)
						File.removeFile(writablePath..k)
					end
				end
			end

			local changeList=Array:ctor()
			for k,v in pairs(nextVerData.assets) do
				if  currVerData.assets[k] then  
					if currVerData.assets[k].md5 ~= v.md5 then
						changeList:push(k)
					end
				else
					changeList:push(k)
				end
			end

			--简单二次校验
			if changeList:length()== moveFileList:length() then
				moveFile(currVersion,nextVersion)
			else
				print("校验失败！")
			end
		end)
	end
end


local function startLoadVerFile(currVersion,nextVersion)
	-- body
	print("当前版本："..currVersion.." 下一版本："..nextVersion)
	loadGameVerFest(nextVersion,function ( ... )
		-- body
		local tab=loadVersionMainfest(writablePath.."ver_files/ver_diff"..nextVersion..".manifest")
		for k,v in pairs(tab.assets) do
			v.path=k
			v.version=nextVersion
			v.loadTime=0
			LoadList:push(v)
		end
		--LoadList:print()
		Event:emit("update_module",{cmd="update_startLoad",data=tab.assets})
		loadFile(currVersion,nextVersion)
	end)
end

local function loadRemoteVersionMainfest(mainVersion,secondVersion,version,func)
	HttpLoad(getPackageUrl().."version.manifest",function ( data,url )
	    -- body
	    print(data)
		local remotversionData=string.gsub(data,"\\","")
		remotversionData=json.decode(remotversionData)
		if mainVersion<tonumber(remotversionData.mainVersion) or secondVersion<tonumber(remotversionData.secondVersion) then
			print("跳转换包")
		else
			if version == remotversionData.version then
				print("进入游戏")
				Event:emit("update_module",{cmd="update_end",data=version})
				if M.enterGame then 
					M.enterGame()
				end
			else
				print("更新游戏")
				if not FileUtils:isDirectoryExist(writablePath.."tmp") then FileUtils:createDirectory(writablePath.."tmp") end

				local tag=false
				local nextVersion=nil
				for i,v in ipairs(remotversionData.versionsList) do
					if tag then
						nextVersion=v
						break
					end
					if v == version then
						tag=true
					end
				end
				Event:emit("update_module",{cmd="update_next_version",data=nextVersion})
				startLoadVerFile(version,nextVersion)
			end
		end
	end)
end


function M.update( func )
	-- body
	M.enterGame=func
	LoadList:clear()
	moveFileList:clear()
	moveToWritablePath()
	local t=loadVersionMainfest(versionPath)
	local mainVersion=tonumber(t.mainVersion)
	local secondVersion=tonumber(t.secondVersion)
	local packageUrl=t.packageUrl
	local version=t.version
	print(mainVersion,secondVersion,version,packageUrl)
	Event:emit("update_module",{cmd="update_version",data=version})
	M.packageUrl=packageUrl
	loadGameMainFest(version,function ( ... )
		-- body
		loadRemoteVersionMainfest(mainVersion,secondVersion,version,func)
	end)
	
end

return M.update

