-- base_shutdown.lua

-----------------------------------------------------------------------------
-- includes
-----------------------------------------------------------------------------
IncludeScript("base");
IncludeScript("base_ctf");
--IncludeScript("base_teamplay");

-----------------------------------------------------------------------------
-- global overrides
-----------------------------------------------------------------------------
POINTS_PER_CAPTURE = 10;
SECURITY_TIME = 30;
	
-----------------------------------------------------------------------------
-- class limits
-----------------------------------------------------------------------------
function startup()

	SetGameDescription( "Capture the Flag" )
	
	-- set up team limits on each team
	SetPlayerLimit(Team.kBlue, 0)
	SetPlayerLimit(Team.kRed, 0)
	SetPlayerLimit(Team.kYellow, -1)
	SetPlayerLimit(Team.kGreen, -1)

	local team = GetTeam(Team.kBlue)
	team:SetClassLimit(Player.kCivilian, -1)
	team:SetClassLimit(Player.kSniper, -1)
	team:SetClassLimit(Player.kPyro, -1)
	
	team = GetTeam(Team.kRed)
	team:SetClassLimit(Player.kCivilian, -1)
	team:SetClassLimit(Player.kSniper, -1)
	team:SetClassLimit(Player.kPyro, -1)
end

-----------------------------------------------------------------------------
-- Buttons
-----------------------------------------------------------------------------

-- base button stuff (common functionality)
button_common = func_button:new({ team = Team.kUnassigned }) 

function button_common:allowed( allowed_entity ) 
	if IsPlayer( allowed_entity ) then
		local player = CastToPlayer( allowed_entity )
		if player:GetTeamId() == self.team and player:IsAlive() then
			return EVENT_ALLOWED
		end
	end

	return EVENT_DISALLOWED
end

-- TODO this doesn't work
function button_common:onfailuse( use_entity )
	if IsPlayer( use_entity ) then
		local player = CastToPlayer( use_entity )
		BroadCastMessageToPlayer( player, "#FF_NOTALLOWEDBUTTON" )
	end
end

-----------------------------------------------------------------------------
-- Button inputs (touch, use, damage etc.)
-----------------------------------------------------------------------------

-- red button
--button_red = button_common:new({ team = Team.kBlue, sec_up = true }) 

button_red = button_common:new({ 
	team = Team.kBlue, 
	sec_up = true, 
	sec_down_icon = "hud_secdown.vtf", 
	sec_up_icon = "hud_secup_red.vtf", 
	iconx = 60,
	icony = 30,
	iconw = 16,
	iconh = 16,
	iconalign = 3
}) 

-----------------------------------------------------------------------------
-- Button responses 
-----------------------------------------------------------------------------
function button_red:onin() 
	BroadCastMessage( "#FF_RED_SECURITY_DEACTIVATED" )
	SpeakAll( "SD_REDDOWN" )

	self.sec_up = false

	RemoveHudItemFromAll( "red-sec-up")
	AddHudIconToAll( self.sec_down_icon, "red-sec-down", self.iconx, self.icony, self.iconw, self.iconh, self.iconalign )
	LogLuaEvent(0, 0, "security_down", "team", "red")
	
	AddHudTimerToAll( "red_sec_timer", SECURITY_TIME, -1, 60, 30, 3 )
	
end 

function button_red:onout()
	BroadCastMessage( "#FF_RED_SECURITY_ACTIVATED" )
	SpeakAll( "SD_REDUP" )

	self.sec_up = true

	RemoveHudItemFromAll( "red-sec-down" )
	AddHudIconToAll( self.sec_up_icon, "red-sec-up", self.iconx, self.icony, self.iconw, self.iconh, self.iconalign )
	LogLuaEvent(0, 0, "security_up", "team", "red")
	
	RemoveHudItemFromAll( "red_sec_timer" )
	
end

-----------------------------------------------------------------------------
-- Button inputs (touch, use, damage etc.)
-----------------------------------------------------------------------------

-- blue button
--button_blue = button_common:new({ team = Team.kRed, sec_up = true }) 

button_blue = button_common:new({ 
	team = Team.kRed, 
	sec_up = true, 
	sec_down_icon = "hud_secdown.vtf", 
	sec_up_icon = "hud_secup_blue.vtf", 
	iconx = 60,
	icony = 30,
	iconw = 16,
	iconh = 16,
	iconalign = 2
}) 

-----------------------------------------------------------------------------
-- Button responses 
-----------------------------------------------------------------------------
function button_blue:onin() 
	BroadCastMessage( "#FF_BLUE_SECURITY_DEACTIVATED" )
	SpeakAll( "SD_BLUEDOWN" )

	self.sec_up = false

	RemoveHudItemFromAll( "blue-sec-up")
	AddHudIconToAll( self.sec_down_icon, "blue-sec-down", self.iconx, self.icony, self.iconw, self.iconh, self.iconalign )
	LogLuaEvent(0, 0, "security_down", "team", "blue")

	AddHudTimerToAll( "blue_sec_timer", SECURITY_TIME, -1, 60, 30, 2 )
		
end 

function button_blue:onout()
	BroadCastMessage( "#FF_BLUE_SECURITY_ACTIVATED" )
	SpeakAll( "SD_BLUEUP" )

	self.sec_up = true

	RemoveHudItemFromAll( "blue-sec-down")
	AddHudIconToAll( self.sec_up_icon, "blue-sec-up", self.iconx, self.icony, self.iconw, self.iconh, self.iconalign )
  LogLuaEvent(0, 0, "security_up", "team", "blue")
  
  RemoveHudItemFromAll( "blue_sec_timer" )

end

-----------------------------------------------------------------------------
-- Hurts
-----------------------------------------------------------------------------
hurt = trigger_ff_script:new({ team = Team.kUnassigned })
function hurt:allowed( allowed_entity )
	if IsPlayer( allowed_entity ) then
		local player = CastToPlayer( allowed_entity )
		if player:GetTeamId() == self.team then
			return EVENT_ALLOWED
		end
	end

	return EVENT_DISALLOWED
end

-- red lasers hurt blue and vice-versa
red_laser_hurt = hurt:new({ team = Team.kBlue })
blue_laser_hurt = hurt:new({ team = Team.kRed })

-------------------------
-- flaginfo
-------------------------

--flaginfo runs whenever the player spawns or uses the flaginfo command.
--Right now it just refreshes the HUD items; this ensures that players who just joined the server have the right information
function flaginfo( player_entity )
	flaginfo_base(player_entity) --see base_teamplay.lua

	local player = CastToPlayer( player_entity )
	
	RemoveHudItem( player, "red-sec-down" )
	RemoveHudItem( player, "blue-sec-down" )
	RemoveHudItem( player, "red-sec-up" )
	RemoveHudItem( player, "blue-sec-up" )

		if button_blue.sec_up == true then
			AddHudIcon( player, button_blue.sec_up_icon, "blue-sec-up", button_blue.iconx, button_blue.icony, button_blue.iconw, button_blue.iconh, button_blue.iconalign )
		else
			AddHudIcon( player, button_blue.sec_down_icon, "blue-sec-down", button_blue.iconx, button_blue.icony, button_blue.iconw, button_blue.iconh, button_blue.iconalign )
		end

		if button_red.sec_up == true then
			AddHudIcon( player, button_red.sec_up_icon, "red-sec-up", button_red.iconx, button_red.icony, button_red.iconw, button_red.iconh, button_red.iconalign )
		else
			AddHudIcon( player, button_red.sec_down_icon, "red-sec-down", button_red.iconx, button_red.icony, button_red.iconw, button_red.iconh, button_red.iconalign )
		end
end

-----------------------------------------------------------------------------
-- Clips on Spawns
-----------------------------------------------------------------------------
clip_brush = trigger_ff_clip:new({ clipflags = 0 })

blue_block 	= clip_brush:new({ clipflags = {ClipFlags.kClipPlayers, ClipFlags.kClipTeamBlue } })
red_block 	= clip_brush:new({ clipflags = {ClipFlags.kClipPlayers, ClipFlags.kClipTeamRed } })

-----------------------------------------------------------------------------
-- backpacks
-----------------------------------------------------------------------------
red_pack = genericbackpack:new({
	grenades = 100,
	bullets = 100,
	nails = 100,
	shells = 100,
	rockets = 100,
	gren1 = 0,
	gren2 = 0,
	cells = 100,
	armor = 40,
	health = 30,
	respawntime = 16,
	model = "models/items/backpack/backpack.mdl",
	materializesound = "Item.Materialize",
	touchsound = "Backpack.Touch",
	touchflags = {AllowFlags.kRed},
	botgoaltype = Bot.kBackPack_Ammo
})

function red_pack:dropatspawn() return false end

red_pack_metal = genericbackpack:new({
	grenades = 100,
	bullets = 100,
	nails = 100,
	shells = 100,
	rockets = 100,
	gren1 = 0,
	gren2 = 0,
	cells = 100,
	armor = 0,
	health = 0,
	respawntime = 16,
	model = "models/items/backpack/backpack.mdl",
	materializesound = "Item.Materialize",
	touchsound = "Backpack.Touch",
	touchflags = {AllowFlags.kRed},
	botgoaltype = Bot.kBackPack_Ammo
})

function red_pack_metal:dropatspawn() return false end

blue_pack = genericbackpack:new({
	grenades = 100,
	bullets = 100,
	nails = 100,
	shells = 100,
	rockets = 100,
	gren1 = 0,
	gren2 = 0,
	cells = 100,
	armor = 40,
	health = 30,
	respawntime = 16,
	model = "models/items/backpack/backpack.mdl",
	materializesound = "Item.Materialize",
	touchsound = "Backpack.Touch",
	touchflags = {AllowFlags.kBlue},
	botgoaltype = Bot.kBackPack_Ammo
})

function blue_pack:dropatspawn() return false end

blue_pack_metal = genericbackpack:new({
	grenades = 100,
	bullets = 100,
	nails = 100,
	shells = 100,
	rockets = 100,
	gren1 = 0,
	gren2 = 0,
	cells = 100,
	armor = 0,
	health = 0,
      respawntime = 16,
	model = "models/items/backpack/backpack.mdl",
	materializesound = "Item.Materialize",
	touchsound = "Backpack.Touch",
	touchflags = {AllowFlags.kBlue},
	botgoaltype = Bot.kBackPack_Ammo
})

function blue_pack_metal:dropatspawn() return false end

resup_pack = genericbackpack:new({
	grenades = 100,
	bullets = 100,
	nails = 100,
	shells = 100,
	rockets = 100,
	gren1 = 0,
	gren2 = 0,
	cells = 130,
	armor = 40,
	health = 50,
	respawntime = 16,
	model = "models/items/backpack/backpack.mdl",
	materializesound = "Item.Materialize",
	touchsound = "Backpack.Touch",
})

function resup_pack:dropatspawn() return false end

-----------------------------------------------------------------------------
-- Spawns
-----------------------------------------------------------------------------

--Red Team
redspawn_offense = function(self,player) return ((player:GetTeamId() == Team.kRed) and ((player:GetClass() == Player.kScout) or (player:GetClass() == Player.kMedic) or (player:GetClass() == Player.kSpy))) end
redspawn_defense_soldier 	= function(self,player) return ((player:GetTeamId() == Team.kRed ) and (player:GetClass() == Player.kSoldier)) end
redspawn_defense_engineer 	= function(self,player) return ((player:GetTeamId() == Team.kRed ) and (player:GetClass() == Player.kEngineer)) end
redspawn_defense_heavy 		= function(self,player) return ((player:GetTeamId() == Team.kRed ) and (player:GetClass() == Player.kHwguy)) end
redspawn_defense_demoman 	= function(self,player) return ((player:GetTeamId() == Team.kRed ) and (player:GetClass() == Player.kDemoman)) end

redspawn_offense 			= { validspawn = redspawn_offense }
redspawn_defense_soldier 	= { validspawn = redspawn_defense_soldier }
redspawn_defense_engineer 	= { validspawn = redspawn_defense_engineer }
redspawn_defense_heavy 		= { validspawn = redspawn_defense_heavy }
redspawn_defense_demoman 	= { validspawn = redspawn_defense_demoman }

--Blue Team
bluespawn_offense = function(self,player) return ((player:GetTeamId() == Team.kBlue) and ((player:GetClass() == Player.kScout) or (player:GetClass() == Player.kMedic) or (player:GetClass() == Player.kSpy))) end
bluespawn_defense_soldier 	= function(self,player) return ((player:GetTeamId() == Team.kBlue ) and (player:GetClass() == Player.kSoldier)) end
bluespawn_defense_engineer 	= function(self,player) return ((player:GetTeamId() == Team.kBlue ) and (player:GetClass() == Player.kEngineer)) end
bluespawn_defense_heavy 	= function(self,player) return ((player:GetTeamId() == Team.kBlue ) and (player:GetClass() == Player.kHwguy)) end
bluespawn_defense_demoman 	= function(self,player) return ((player:GetTeamId() == Team.kBlue ) and (player:GetClass() == Player.kDemoman)) end

bluespawn_offense 			= { validspawn = bluespawn_offense }
bluespawn_defense_soldier 	= { validspawn = bluespawn_defense_soldier }
bluespawn_defense_engineer 	= { validspawn = bluespawn_defense_engineer }
bluespawn_defense_heavy 	= { validspawn = bluespawn_defense_heavy }
bluespawn_defense_demoman 	= { validspawn = bluespawn_defense_demoman }

-----------------------------------------------------------------------------
-- bouncepads for lifts
-----------------------------------------------------------------------------
base_jump = trigger_ff_script:new({ pushz = 0 })

function base_jump:ontouch( trigger_entity )
	if IsPlayer( trigger_entity ) then
		local player = CastToPlayer( trigger_entity )
		local playerVel = player:GetVelocity()
		playerVel.z = self.pushz
		player:SetVelocity( playerVel )
	end
end

lift_red = base_jump:new({ pushz = 600 })
lift_blue = base_jump:new({ pushz = 600 })
