local wwww = {}
--blur
local blur = Material( "pp/blurscreen" )
function wwww.blur( panel, layers, density, alpha )
    local x, y = panel:LocalToScreen(0, 0)
    surface.SetDrawColor( 255, 255, 255, alpha )
    surface.SetMaterial( blur )
    for i = 1, 3 do
        blur:SetFloat( "$blur", ( i / layers ) * density )
        blur:Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect( -x, -y, ScrW(), ScrH() )
    end
end
--outline
wwww.outline = function( x, y, w, h, col )
    surface.SetDrawColor(col)
    surface.DrawOutlinedRect(x,y,w,h)
end
--rally creation menu
local rallymenuopen = false
net.Receive("rallymenu", function(len,ply)
	if rallymenuopen then return end
	rallymenuopen = true
	local rallymenu = vgui.Create("DFrame")
	rallymenu:SetSize(700,400)
	rallymenu:Center()
	rallymenu:MakePopup()
	rallymenu:ShowCloseButton(false)
	rallymenu:SetTitle("")
	rallymenu:SetDraggable(false)
	rallymenu.Paint = function(self,w,h)
		wwww.blur(self,10,20,200)
		draw.RoundedBox(0,0,0,w,h,Color(0,0,0,220))
		surface.SetDrawColor(255,255,255)
		surface.DrawOutlinedRect(0,0,w,h)
		draw.SimpleText("Rallypoint Creator", "DermaLarge", self:GetWide()/2, 25, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("Optional: Choose a name for your rallypoint. If you leave this blank it will take your name.", "DermaDefault", self:GetWide()/2, 80, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("Optional: Choose a duration for your rallypoint. Default duration is 5 minutes.", "DermaDefault", self:GetWide()/2, 140, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	rallymenu.close = vgui.Create("DButton", rallymenu)
	rallymenu.close:SetSize(100,22)
	rallymenu.close:SetPos(rallymenu:GetWide()/2-(rallymenu.close:GetWide()/2),rallymenu:GetTall()-rallymenu.close:GetTall()-20)
	rallymenu.close:SetText("Cancel")
	rallymenu.close:SetTextColor(Color(255,0,0))
	rallymenu.close.DoClick = function() -- Closes the menu
		rallymenu:Close()
		rallymenuopen = false
	end
	rallymenu.close.Paint = function(self,w,h)
		draw.RoundedBox(0,0,0,w,h,Color(0,0,0,179))
		wwww.outline(0,0,w,h,Color(255,255,255))
		if self:IsHovered() then
			surface.SetDrawColor(255,0,0)
			surface.DrawOutlinedRect(0,0,w,h)
		end
	end

	// Text entry element for users to input a name. (eg Event Spawnpoint). Will take the player's name if left blank (eg Dylan's Rallypoint)
	rallymenu.textentry = vgui.Create("DTextEntry", rallymenu)
	rallymenu.textentry:SetSize(234,22)
	rallymenu.textentry:SetPos(rallymenu:GetWide()/2-rallymenu.textentry:GetWide()/2,100)
	rallymenu.textentry:SetEditable(true)
	rallymenu.textentry.Paint = function(self,w,h)
		draw.RoundedBox(0,0,0,w,h,Color(0,0,0,179))
		wwww.outline(0,0,w,h,Color(255,255,255))
		if self:IsEditing() then
			wwww.outline(0,0,w,h,Color(35,255,160))
		end
		if not self:GetValue() or self:GetValue() == "" then
			draw.SimpleText(LocalPlayer():Name().."'s Rallypoint (Click to edit)", "DermaDefault", 3, self:GetTall()/2-1, Color(35,255,160), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		else
			draw.SimpleText(self:GetValue(), "DermaDefault", 3, self:GetTall()/2-1, Color(35,255,160), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
	end

	// Slider element that allows the user to drag a button across an x-axis to increase or decrease the duration of the rally point. Set to 5 minutes if left blank.
    rallymenu.slider = vgui.Create( "DNumSlider", rallymenu )
    rallymenu.slider:SetPos( 18, 155 )     
    rallymenu.slider:SetSize( 500, 100 )
    rallymenu.slider:SetText( "" )  
    rallymenu.slider:SetMin( 1 )     
    rallymenu.slider:SetMax( 30 )   
    rallymenu.slider:SetDecimals( 0 )  
    rallymenu.slider:SetValue(5)
    local tall = 22
    rallymenu.slider.Paint = function(self,w,h)
        surface.SetDrawColor(0, 0, 0, 179)
        surface.DrawRect(216, h / 4-3, w-268, h / 2+6)
        local barw = (w-268) * ( math.Clamp(rallymenu.slider:GetValue()-30, 0, rallymenu.slider:GetMax()) / rallymenu.slider:GetMax())
   		surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawRect(216, h / 4-3, barw, h / 2+6)
        self.Slider.Knob:SetHeight(tall / 2 + 4) -- Makes sure knob matches slider
        DSlider.SetHeight(self, tall) -- Original functionality
        wwww.outline(216, h / 4-3, w-268, h / 2+6,(Color(255,255,255)))
        if rallymenu.slider:IsEditing() then
            wwww.outline(216, h / 4-3, w-268, h / 2+6,Color(35,255,160))
        end
    end
    rallymenu.slider.SetTall = rallymenu.slider.SetHeight -- Alias needs to be same
    rallymenu.slider.Slider.Knob:SetTall(20) -- Default size
    function rallymenu.slider.Slider.Knob:Paint(w, h)-- Paint slider knob
        derma.SkinHook( "Paint", "Button", self, w, h )
        surface.SetDrawColor(60, 60, 60) 
        surface.DrawRect(0, -1, w, h+2)
        draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,179))
        wwww.outline(-1,-1,w+2,h+2,Color(255,255,255))
        if self:IsHovered() then
            draw.RoundedBox(0,0,0,w,h, Color(155,155,155, 10))
            wwww.outline(-1,-1,w+2,h+2,Color(35,255,160))
        end
        if rallymenu.slider:IsEditing() then
            draw.RoundedBox(0,0,0,w,h, Color(155,155,155, 10))
            wwww.outline(-1,-1,w+2,h+2,Color(35,255,160))
        end
    end
    rallymenu.slider.Slider:SetNotches(0)
    local slidertext = rallymenu.slider:GetTextArea()
    slidertext.Paint = function(self,w,h)
    end
    rallymenu.text = vgui.Create("DLabel", rallymenu)
    rallymenu.text:SetSize(rallymenu:GetWide(),450)
    rallymenu.text:CenterHorizontal()
    rallymenu.text:SetText("")
    rallymenu.text.Paint = function(self,w,h)
        local secs = math.floor(rallymenu.slider:GetValue())
        draw.SimpleText("Rally point will expire after:", "DermaDefault", self:GetWide()/2-80, 190, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(secs.." min", "DermaDefault", self:GetWide()/2+55, 190, Color(35,255,160), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    rallymenu.create = vgui.Create("DButton", rallymenu)
    rallymenu.create:SetSize(100,22)
    rallymenu.create:SetPos(rallymenu:GetWide()/2-rallymenu.create:GetWide()/2,210)
    rallymenu.create:SetText("Create Rallypoint")
    rallymenu.create:SetTextColor(Color(35,255,160))
    rallymenu.create.Paint = function(self,w,h)
		draw.RoundedBox(0,0,0,w,h,Color(0,0,0,179))
		wwww.outline(0,0,w,h,Color(255,255,255))
		if self:IsHovered() then
			surface.SetDrawColor(35,255,160)
			surface.DrawOutlinedRect(0,0,w,h)
		end
	end
	// Sends all arguments for the rallypoint to the server, and the server will create the rally point based on these arguments provided that the player meets the requirements to do so.
	rallymenu.create.DoClick = function(self,w,h) 
		rallymenu:Close()
		rallymenuopen = false
		local rallyname = nil
		local rallytime = nil
		if not rallymenu.textentry:GetValue() or rallymenu.textentry:GetValue() == "" then
			rallyname = LocalPlayer():Name().."'s Rallypoint"
		else
			rallyname = rallymenu.textentry:GetValue()
		end
		if not rallymenu.slider:GetValue() or rallymenu.slider:GetValue() == "" or rallymenu.slider:GetValue() == 0 then
			rallytime = 5
		else
			rallytime = rallymenu.slider:GetValue()
		end
		net.Start("createrallypoint")
			net.WriteString(rallyname)
			net.WriteDouble(math.ceil(rallytime))
		net.SendToServer()
	end
end )

local choosemenu = false

// Lets players choose between spawn points
net.Receive("choosespawn", function(len, ply)
	if choosemenu then return end
	choosemenu = true
	local choosespawn = vgui.Create("DFrame")
	choosespawn:SetSize(700,400)
	choosespawn:Center()
	choosespawn:MakePopup()	
	choosespawn:ShowCloseButton(false)
	choosespawn:SetTitle("")
	choosespawn:SetDraggable(false)
	choosespawn.Paint = function(self,w,h)
		wwww.blur(self,10,20,200)
		draw.RoundedBox(0,0,0,w,h,Color(0,0,0,220))
		surface.SetDrawColor(255,255,255)
		surface.DrawOutlinedRect(0,0,w,h)
		draw.SimpleText("Choose Deployment Position", "DermaLarge", self:GetWide()/2, 25, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	choosespawn.scrollbase = vgui.Create("DPanel", choosespawn)
	choosespawn.scrollbase:SetSize(choosespawn:GetWide()-2, choosespawn:GetTall()-105)
	choosespawn.scrollbase:SetPos(1,50)
	choosespawn.scrollbase.Paint = function(self,w,h)
		draw.RoundedBox(0,0,0,w,h,Color(0,0,0,179))
		wwww.outline(-1,0,w+2,h,Color(255,255,255))
	end
	choosespawn.scroll = vgui.Create("DScrollPanel", choosespawn.scrollbase)
	choosespawn.scroll:Dock(FILL)


	choosespawn.close = vgui.Create("DButton", choosespawn)
	choosespawn.close:SetSize(100,22)
	choosespawn.close:SetPos(choosespawn:GetWide()/2-(choosespawn.close:GetWide()/2),choosespawn:GetTall()-choosespawn.close:GetTall()-20)
	choosespawn.close:SetText("Close")
	choosespawn.close:SetTextColor(Color(255,0,0))
	choosespawn.close.DoClick = function()
		choosespawn:Close()
		choosemenu = false
	end
	choosespawn.close.Paint = function(self,w,h)
		draw.RoundedBox(0,0,0,w,h,Color(0,0,0,179))
		wwww.outline(0,0,w,h,Color(255,255,255))
		if self:IsHovered() then
			surface.SetDrawColor(255,0,0)
			surface.DrawOutlinedRect(0,0,w,h)
		end
	end
	local totalrallies = net.ReadDouble()
	for i = 1, totalrallies+1 do
		local rallyname = nil
		local rallyexpiry = nil
		local rallyowner = nil
		local rallyid = nil
		if i ==1 then
			rallyname = "Default (Barracks)"
			rallyexpiry = "Never"
			rallyowner = false
			rallyid = 0
		else
			rallyname = net.ReadString()
			rallyexpiry = net.ReadDouble()
			rallyowner = net.ReadString()
			rallyid = net.ReadDouble()
		end
		local rallypanel = choosespawn.scroll:Add("DPanel")
		rallypanel:SetSize( choosespawn:GetWide(), 50 )
		rallypanel:Dock( TOP )
		rallypanel:DockMargin( 0, 0, 0, 5 )
		rallypanel.Paint = function(self,w,h)
			draw.RoundedBox(0,0,0,w,h,Color(0,0,0,179))
			wwww.outline(0,0,w,h,Color(255,255,255))
			draw.SimpleText(rallyname, "DermaDefault", 3, 10, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			if i == 1 then
				draw.SimpleText("Permanent", "DermaDefault", 3, self:GetTall()/2, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			else
				draw.SimpleText("Expires in: "..rallyexpiry-os.time().." sec", "DermaDefault", 3, self:GetTall()/2, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end
		end

		rallypanel.go = vgui.Create("DButton", rallypanel)
		rallypanel.go:SetSize(75,25)
		rallypanel.go:SetPos(rallypanel:GetWide()/2-rallypanel.go:GetWide()/2, 25)
		rallypanel.go.Paint = function(self,w,h)
			draw.RoundedBox(0,0,0,w,h,Color(0,0,0,179))
			wwww.outline(0,0,w,h,Color(255,255,255))
			if self:IsHovered() then
				surface.SetDrawColor(35,255,160)
				surface.DrawOutlinedRect(0,0,w,h)
			end
		end
		rallypanel.go:SetText("Deploy Here")
		rallypanel.go:SetTextColor(Color(35,255,160))
		rallypanel.go.DoClick = function()
				choosespawn:Close()
				choosemenu = false
			if i == 1 then
				return
			else
				net.Start("choosespawn")
					net.WriteDouble(rallyid)
				net.SendToServer()
			end
		end
	end
        local ScrollBar = choosespawn.scroll:GetVBar();
        ScrollBar.Paint = function(self,w,h)
            draw.RoundedBox(0,0,0,w,h,Color(0,0,0,179))
            --draw.RoundedBox(0,0,0,w,h,Color(35,255,160))
        end
        ScrollBar.btnUp.Paint = function(self, w, h)
            draw.RoundedBox(0,0,0,w,h,Color(0,0,0,179))
            draw.SimpleText("▲", "cux_18", self:GetWide()/2-1, -1, Color(35,255,160), TEXT_ALIGN_CENTER)
            surface.SetDrawColor(Color(35,255,160))
            surface.DrawOutlinedRect(0,0,w,h)
        end

        ScrollBar.btnDown.Paint = function(self, w, h)
            draw.RoundedBox(0,0,0,w,h,Color(0,0,0,179))
            draw.SimpleText("▼", "cux_18", self:GetWide()/2-1, -1, Color(35,255,160), TEXT_ALIGN_CENTER)
            surface.SetDrawColor(Color(35,255,160))
            surface.DrawOutlinedRect(0,0,w,h)
        end

        ScrollBar.btnGrip.Paint = function(self, w, h)
            draw.RoundedBox(0,0,0,w,h,Color(0,0,0,179))
            draw.SimpleText("↕", "cux_18", self:GetWide()/2, self:GetTall()/2, Color(35,255,160), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            surface.SetDrawColor(Color(35,255,160))
            surface.DrawOutlinedRect(0,0,w,h)
        end
end )