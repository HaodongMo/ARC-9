ARC9.AllLuaFilesLoaded = true

net.Receive("arc9_svattcount", function(len, ply)
    if net.ReadUInt(16) != #ARC9.Attachments_Index then
        print("ARC9: too many lua files!! attachment table do not match between client and server!")
        ARC9.AllLuaFilesLoaded = false
    end
end)