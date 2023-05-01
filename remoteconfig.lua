local init_server = false


addHook("ThinkFrame", do
    if init_server == false then
        local rc = io.openlocal("RemoteConfig/1.cfg", "r+")
        if rc then
            for line in rc:lines() do
                if isserver or isdedicatedserver then
                    COM_BufInsertText(server, line)
                end
            end
        end
        init_server = true
    end
end)