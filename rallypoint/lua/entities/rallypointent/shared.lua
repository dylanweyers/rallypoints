ENT.Type = "anim"
ENT.Base = "base_gmodentity"
 
ENT.PrintName		= "Glowball"
ENT.Author			= "Ricky26"
ENT.Contact			= "Don't"
ENT.Purpose			= "Exemplar material"
ENT.Instructions	= "Use with care. Always handle with gloves."

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "RallyName")
	if SERVER then
		if not self:GetRallyName() or self:GetRallyName() == "" then
			self:SetRallyName("Rally Point")
		end
	end
end