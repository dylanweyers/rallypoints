// Include serverside and clientside lua files
if SERVER then
	include("rallypoint/server/sv_rallypoint.lua")
	include("rally_config.lua")
	AddCSLuaFile("rallypoint/client/cl_rallypoint.lua")
else
	include("rallypoint/client/cl_rallypoint.lua")
end