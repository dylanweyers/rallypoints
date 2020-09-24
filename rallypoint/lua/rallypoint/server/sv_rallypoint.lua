--Netstrings
util.AddNetworkString("rallymenu")
util.AddNetworkString("createrallypoint")
util.AddNetworkString("choosespawn")
--Spawnpos table
local rallypoints = {}
--Command
local cmd = "/rallypoint"
hook.Add("PlayerSay", "deployRallyPoint", function(ply, text)
	if string.sub(string.lower(text),1,#cmd) == cmd then
		local playerjob = RPExtraTeams[ply:Team()]
		if rallycfg.Categories[playerjob.category] or rallycfg.Ranks[ply:GetUserGroup()] then
			net.Start("rallymenu")
			net.Send(ply)
		else
			ply:ChatPrint("You can't use this command.")
		end
	end
end )
--Create rally point if player has the correct job/team or in-game rank
net.Receive("createrallypoint", function(len,  ply)
	local playerjob = RPExtraTeams[ply:Team()]
	if rallycfg.Categories[playerjob.category] or rallycfg.Ranks[ply:GetUserGroup()] then
		local rallyname = net.ReadString()
		local rallytime = net.ReadDouble()*60
		local pos = ply:GetPos()
		local starttime = SysTime()
		local index = table.Count(rallypoints)+1
		table.insert(rallypoints, { --Inserts name, start time, duration, expiry time, position, the name of the person who created the spawn point and the index of the rally point to the rally point table.
			name = rallyname,
			start = starttime,
			duration = rallytime*60,
			expirytime = os.time()+(rallytime),
			spawnpos = pos,
			rallyowner = ply:Name(),
			id = index
		})
		local rallypoint = ents.Create("rallypointent")
		rallypoint:SetPos(ply:GetPos())
		rallypoint:Spawn()
		rallypoint:SetRallyName(rallyname)
		timer.Simple(rallytime, function()
			for k, v in pairs(rallypoints) do
				if v.id == index then
					table.remove(rallypoints,k)
					print("Rallypoint "..v.name.." has expired after "..v.duration.." seconds at "..math.floor(v.expirytime))
					rallypoint:Remove()
					break
				end
			end
		end)
	else 
		ply:ChatPrint("You cannot create rallypoints")
	end
end )
--check tables for debugging
hook.Add("PlayerSay", "checkRallies", function(__, text)
	if text == "/rallies" then
		PrintTable(rallypoints)
	end
end )
--send spawn menu net message to player
hook.Add("PlayerSpawn", "chooseSpawn", function(ply)
	net.Start("choosespawn")
	net.WriteDouble(table.Count(rallypoints))
	for k, v in pairs(rallypoints) do
		net.WriteString(v.name)
		net.WriteDouble(v.expirytime)
		net.WriteString(v.rallyowner)
		net.WriteDouble(v.id)
	end
	net.Send(ply)
end )
--teleport player to their chosen spawn point
net.Receive("choosespawn", function(len, ply)
	local rallyid = net.ReadDouble()
	local found = false
	for k, v in pairs(rallypoints) do
		if v.id == rallyid then
			ply:SetPos(v.spawnpos)
			return
		end
	end
	ply:ChatPrint("Invalid rally point. (Expired)")
end )