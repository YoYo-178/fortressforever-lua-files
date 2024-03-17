----------------------------------------------------------------------
-- Includes
----------------------------------------------------------------------

IncludeScript("base_respawnturret")

----------------------------------------------------------------------
-- Definitions
----------------------------------------------------------------------

BALL_RETURN_TIME = 0
SCORE_TIME = 5
ADD_POINTS = 1
POINT_MULTIPLIER = 10

----------------------------------------------------------------------
-- Startup
----------------------------------------------------------------------

function startup()
	SetTeamName(Team.kBlue, "Blue Orcas")
	SetTeamName(Team.kRed, "Red Gazelles")
	SetTeamName(Team.kYellow, "Yellow Llamas")
	SetTeamName(Team.kGreen, "Green Parrots")
	
	SetPlayerLimit(Team.kBlue, 8)
	SetPlayerLimit(Team.kRed, 8)
	SetPlayerLimit(Team.kYellow, 8)
	SetPlayerLimit(Team.kGreen, 8)

	local team = GetTeam(Team.kBlue)
	team:SetClassLimit(Player.kCivilian, -1)
	
	team = GetTeam(Team.kRed)
	team:SetClassLimit(Player.kCivilian, -1)
	
	team = GetTeam(Team.kYellow)
	team:SetClassLimit(Player.kCivilian, -1)
	
	team = GetTeam(Team.kGreen)
	team:SetClassLimit(Player.kCivilian, -1)
end

----------------------------------------------------------------------
-- Door Triggers
----------------------------------------------------------------------

respawndoor = trigger_ff_script:new({team = Team.kUnassigned, allowdisguised = false})

function respawndoor:allowed(allowed_entity)
	local isallowed = false
	if IsPlayer(allowed_entity) then
		local player = CastToPlayer(allowed_entity)
		
		if player:GetTeamId() == self.team then
			isallowed = true
		end
		
		if self.allowdisguised then
			if player:IsDisguised() and player:GetDisguisedTeam() == self.team then
				isallowed = true
			end
		end
	end
	return isallowed
end

function respawndoor:onfailtouch(touch_entity)
	if IsPlayer(touch_entity) then
		local player = CastToPlayer(touch_entity)
		BroadCastMessageToPlayer(player, "#FF_NOTALLOWEDDOOR")
	end
end

bluerespawndoor = respawndoor:new({team = Team.kBlue})
redrespawndoor = respawndoor:new({team = Team.kRed})
yellowrespawndoor = respawndoor:new({team = Team.kYellow})
greenrespawndoor = respawndoor:new({team = Team.kGreen})

----------------------------------------------------------------------
-- Respawn
----------------------------------------------------------------------

redallowedmethod = function(self,player) return player:GetTeamId() == Team.kRed end
blueallowedmethod = function(self,player) return player:GetTeamId() == Team.kBlue end
yellowallowedmethod = function(self,player) return player:GetTeamId() == Team.kYellow end
greenallowedmethod = function(self,player) return player:GetTeamId() == Team.kGreen end

redspawn = {validspawn = redallowedmethod}
bluespawn = {validspawn = blueallowedmethod}
greenspawn = {validspawn = greenallowedmethod}
yellowspawn = {validspawn = yellowallowedmethod}

----------------------------------------------------------------------
-- Generic Backpack
----------------------------------------------------------------------

genericbackpack = info_ff_script:new({
	health = 0,
	armor = 0,
	grenades = 0,
	bullets = 0,
	nails = 0,
	rockets = 0,
	cells = 0,
	detpacks = 0,
	gren1 = 0,
	gren2 = 0,
	respawntime = 5,
	model = "models/items/healthkit.mdl",
	materializesound = "Item.Materialize",
	touchsound = "HealthKit.Touch",
	notallowedmsg = "#FF_NOTALLOWEDPACK",
	touchflags = {AllowFlags.kOnlyPlayers, AllowFlags.kRed, AllowFlags.kBlue, AllowFlags.kYellow, AllowFlags.kGreen},
	noball = false
})

function genericbackpack:precache()
	PrecacheSound(self.materializesound)
	PrecacheSound(self.touchsound)
	PrecacheModel(self.model)
end

function genericbackpack:touch(touch_entity)
	if IsPlayer(touch_entity) then
		local player = CastToPlayer(touch_entity)
		local dispensed = 0

		if self.noball and HasBall(player) then return; end

		if self.health ~= nil then
			dispensed = dispensed + player:AddHealth(self.health)
		end
		if self.armor ~= nil then
			dispensed = dispensed + player:AddArmor(self.armor)
		end
		if self.nails ~= nil then
			dispensed = dispensed + player:AddAmmo(Ammo.kNails, self.nails)
		end
		if self.shells ~= nil then
			dispensed = dispensed + player:AddAmmo(Ammo.kShells, self.shells)
		end
		if self.rockets ~= nil then
			dispensed = dispensed + player:AddAmmo(Ammo.kRockets, self.rockets)
		end
		if self.cells ~= nil then
			dispensed = dispensed + player:AddAmmo(Ammo.kCells, self.cells)
		end
		if self.detpacks ~= nil then
			dispensed = dispensed + player:AddAmmo(Ammo.kDetpack, self.detpacks)
		end
		if self.gren1 ~= nil then
			dispensed = dispensed + player:AddAmmo(Ammo.kGren1, self.gren1)
		end
		if self.gren2 ~= nil then
			dispensed = dispensed + player:AddAmmo(Ammo.kGren2, self.gren2)
		end
	
		if dispensed >= 1 then
			local backpack = CastToInfoScript(entity);
			if (backpack ~= nil) then
				backpack:EmitSound(self.touchsound);
				backpack:Respawn(self.respawntime);
			end
		end
	end
end

function genericbackpack:materialize() entity:EmitSound(self.materializesound) end
function genericbackpack:dropatspawn() return false end

----------------------------------------------------------------------
-- Health Kits
----------------------------------------------------------------------

healthkitgeneric = genericbackpack:new({
	health = 25,
	model = "models/items/healthkit.mdl",
	materializesound = "Item.Materialize",
	respawntime = 20,
	touchsound = "HealthKit.Touch",
	botgoaltype = Bot.kBackPack_Health
})

function healthkitgeneric:dropatspawn() return true end

----------------------------------------------------------------------
-- Ammo Kits
----------------------------------------------------------------------

ammobackpackgeneric = genericbackpack:new({
	grenades = 25,
	bullets = 100,
	nails = 100,
	shells = 100,
	rockets = 25,
	cells = 100,
	model = "models/items/backpack/backpack.mdl",
	materializesound = "Item.Materialize",
	respawntime = 15,
	touchsound = "Backpack.Touch",
	botgoaltype = Bot.kBackPack_Ammo
})

----------------------------------------------------------------------
-- Grenade Backpack
----------------------------------------------------------------------

grenadebackpackgeneric = genericbackpack:new({
	gren1 = 4,
	gren2 = 4,
	model = "models/items/backpack/backpack.mdl",
	materializesound = "Item.Materialize",
	respawntime = 90,
	touchsound = "Backpack.Touch",
	botgoaltype = Bot.kBackPack_Grenades,
	noball = true
})

----------------------------------------------------------------------
-- Armor Kit
----------------------------------------------------------------------

armorkitgeneric = genericbackpack:new({
	armor = 200,
	cells = 150,
	model = "models/items/armour/armour.mdl",
	materializesound = "Item.Materialize",
	respawntime = 5,	
	touchsound = "ArmorKit.Touch",
	botgoaltype = Bot.kBackPack_Armor,
	noball = true
})

function armorkitgeneric:dropatspawn() return true end

----------------------------------------------------------------------
-- Setup Backpacks
----------------------------------------------------------------------

function build_backpacks(tf)
	return healthkitgeneric:new({touchflags = tf}),
		ammobackpackgeneric:new({touchflags = tf}),
		grenadebackpackgeneric:new({touchflags = tf}),
		armorkitgeneric:new({touchflags = tf})
end

healthkitblue, ammobackpackblue, grenadebackpackblue, armorkitblue = build_backpacks({AllowFlags.kOnlyPlayers, AllowFlags.kBlue})
healthkitred, ammobackpackred, grenadebackpackred, armorkitred = build_backpacks({AllowFlags.kOnlyPlayers, AllowFlags.kRed})
healthkityellow, ammobackpackyellow, grenadebackpackyellow, armorkityellow = build_backpacks({AllowFlags.kOnlyPlayers, AllowFlags.kYellow})
healthkitgreen, ammobackpackgreen, grenadebackpackgreen, armorkitgreen = build_backpacks({AllowFlags.kOnlyPlayers, AllowFlags.kGreen})

----------------------------------------------------------------------
-- Ball Setup
----------------------------------------------------------------------

base_ball = info_ff_script:new({
	name = "base ball",
	team = Team.kUnassigned,
	model = "models/items/ball/ball.mdl",
	modelskin = 0,
	tosssound = "Flag.Toss",
	capnotouchtime = 1,
	dropnotouchtime = 1,
	status = 0,
	hudicon = "hud_ball",
	hudx = 5,
	hudy = 210,
	hudw = 48,
	hudh = 48,
	huda = 1,
	hudstatusiconxrb = 60,
	hudstatusiconyrb = 5,
	hudstatusiconxyg = 53,
	hudstatusiconyyg = 25,
	hudstatusicon = "hud_ball.vtf",
	hudstatusiconw = 15,
	hudstatusiconh = 15,
	hudstatusiconalignby = 2,
	hudstatusiconalignrg = 3,
	botgoaltype = Bot.kFlag,
	touchflags = {AllowFlags.kOnlyPlayers, AllowFlags.kBlue, AllowFlags.kRed, AllowFlags.kYellow, AllowFlags.kGreen}
})

function base_ball:hasanimation() return true end

function base_ball:attachoffset() return Vector(32, 0, 0) end

function base_ball:precache()
	PrecacheSound(self.tosssound)
	PrecacheSound("yourteam.flagstolen")
	PrecacheSound("otherteam.flagstolen")
	PrecacheSound("yourteam.drop")
	PrecacheSound("otherteam.drop")
	PrecacheSound("yourteam.flagreturn")
	PrecacheSound("otherteam.flagreturn")
	PrecacheSound("yourteam.flagcap")
	PrecacheSound("otherteam.flagcap")
	info_ff_script.precache(self)
end

function base_ball:spawn()
	self.notouch = {}
	info_ff_script.spawn(self)
	self.status = 0
end

function base_ball:addnotouch(player_id, duration)
	self.notouch[player_id] = duration
	AddSchedule(self.name.."-"..player_id, duration, self.removenotouch, self, player_id)	
end

function base_ball.removenotouch(self, player_id)
	self.notouch[player_id] = nil
end

function base_ball:touch(touch_entity)
	if IsPlayer(touch_entity) then
		local player = CastToPlayer(touch_entity)
		if self.notouch[player:GetId()] then return; end
	
		if player:GetTeamId() ~= self.team then
			SmartSound(player, "yourteam.flagstolen", "yourteam.flagstolen", "otherteam.flagstolen")
			SmartSpeak(player, "CTF_YOUHAVEBALL", "CTF_TEAMHASBALL", "CTF_ENEMYHASBALL")
			SmartMessage(player, "You have the ball! Don't get murdered!", "#FF_TEAMHASBALL", "#FF_ENEMYHASBALL")
			
			player:SetDisguisable(false)
			player:SetCloakable(false)
			
			local ball = CastToInfoScript(entity)
			ball:Pickup(player)
			self.status = 1
			AddHudIcon(player, self.hudicon, ball:GetName(), self.hudx, self.hudy, self.hudw, self.hudh, self.huda)
			RemoveHudItemFromAll("ball-icon-dropped")

			local team = player:GetTeamId()
			if (team == Team.kBlue) then
				AddHudIconToAll(self.hudstatusicon, "ball-icon-blue", self.hudstatusiconxrb, self.hudstatusiconyrb, self.hudstatusiconw, self.hudstatusiconh, self.hudstatusiconalignby)
			elseif (team == Team.kRed) then
				AddHudIconToAll(self.hudstatusicon, "ball-icon-red", self.hudstatusiconxrb, self.hudstatusiconyrb, self.hudstatusiconw, self.hudstatusiconh, self.hudstatusiconalignrg)
			elseif (team == Team.kYellow) then
				AddHudIconToAll(self.hudstatusicon, "ball-icon-yellow", self.hudstatusiconxyg, self.hudstatusiconyyg, self.hudstatusiconw, self.hudstatusiconh, self.hudstatusiconalignby)
			elseif (team == Team.kGreen) then
				AddHudIconToAll(self.hudstatusicon, "ball-icon-green", self.hudstatusiconxyg, self.hudstatusiconyyg, self.hudstatusiconw, self.hudstatusiconh, self.hudstatusiconalignrg)
			end
			
			AddScheduleRepeating("scoretimer", SCORE_TIME, AddPoints, player)
		end
	end
end

function base_ball:onownerdie(owner_entity)
	local ball = CastToInfoScript(entity)
	ball:Drop(BALL_RETURN_TIME, 0.0)
	self.status = 2
	if IsPlayer(owner_entity) then
		local player = CastToPlayer(owner_entity)
		RemoveHudItem(player, ball:GetName())

		local team = player:GetTeamId()
		if (team == Team.kBlue) then
			RemoveHudItemFromAll("ball-icon-blue")
		elseif (team == Team.kRed) then
			RemoveHudItemFromAll("ball-icon-red")
		elseif (team == Team.kYellow) then
			RemoveHudItemFromAll("ball-icon-yellow")
		elseif (team == Team.kGreen) then
			RemoveHudItemFromAll("ball-icon-green")
		end
	end
end

function base_ball:ownerfeign(owner_entity)
	local ball = CastToInfoScript(entity)
	ball:Drop(BALL_RETURN_TIME, 0.0)
	self.status = 2
	if IsPlayer(owner_entity) then
		local player = CastToPlayer(owner_entity)
		RemoveHudItem(player, ball:GetName())

		local team = player:GetTeamId()
		if (team == Team.kBlue) then
			RemoveHudItemFromAll("ball-icon-blue")
		elseif (team == Team.kRed) then
			RemoveHudItemFromAll("ball-icon-red")
		elseif (team == Team.kYellow) then
			RemoveHudItemFromAll("ball-icon-yellow")
		elseif (team == Team.kGreen) then
			RemoveHudItemFromAll("ball-icon-green")
		end
	end
end

function base_ball:dropitemcmd(owner_entity) return false end

function base_ball:ondrop(owner_entity)
	if IsPlayer(owner_entity) then
		local player = CastToPlayer(owner_entity)
		SmartSound(player, "yourteam.drop", "yourteam.drop", "otherteam.drop")
		SmartMessage(player, "#FF_YOUBALLDROP", "#FF_TEAMBALLDROP", "#FF_ENEMYBALLDROP")
		RemoveSchedule("scoretimer")
	end
	
	local ball = CastToInfoScript(entity)
	ball:EmitSound(self.tosssound)
end

function base_ball:onloseitem(owner_entity)
	if IsPlayer(owner_entity) then
		local player = CastToPlayer(owner_entity)
		player:SetDisguisable(true)
		player:SetCloakable(true)
		self:addnotouch(player:GetId(), self.capnotouchtime)
	end
end

function base_ball:onreturn()
	BroadCastMessage("#FF_BALLRETURN")
	BroadCastSound ("yourteam.flagreturn")
	SpeakAll("CTF_BALLRETURN")
	self.status = 0
end

ball = base_ball:new({name = "Murderball"})

----------------------------------------------------------------------
-- Add Points
----------------------------------------------------------------------

function AddPoints(player_entity)
	if IsPlayer(player_entity) then
		local player = CastToPlayer(player_entity)
		local team = player:GetTeam()
		team:AddScore(ADD_POINTS)
		player:AddFortPoints(ADD_POINTS*POINT_MULTIPLIER, "Holding the ball.")
	end
end

----------------------------------------------------------------------
-- Has Ball
----------------------------------------------------------------------

function HasBall(player_entity)
	if IsPlayer(player_entity) then
		local player = CastToPlayer(player_entity)
		local ball = GetInfoScriptByName("ball")
		if ball then
			if player:HasItem(ball:GetName()) then
				return true
			end
		end
	end
	return false
end

----------------------------------------------------------------------
-- Ball Triggers
----------------------------------------------------------------------

hasball_trigger = trigger_ff_script:new({})

function hasball_trigger:allowed(allowed_entity)
	if IsPlayer(allowed_entity) then
		local player = CastToPlayer(allowed_entity)
		if HasBall(player) then
			return true
		end
	end
	return false
end

blue_base = hasball_trigger:new({})
red_base = hasball_trigger:new({})
yellow_base = hasball_trigger:new({})
green_base = hasball_trigger:new({})
spawn_antiball = hasball_trigger:new({})

----------------------------------------------------------------------
-- Locations
----------------------------------------------------------------------

location_info = trigger_ff_script:new({text = "Unknown", team = Team.kUnassigned})

function location_info:ontouch(touch_entity)
	if IsPlayer(touch_entity) then
		local player = CastToPlayer(touch_entity)
		player:SetLocation(entity:GetId(), self.text, self.team)
	end
end

location_blue_base = location_info:new({text = "Center Room", team = Team.kBlue})
location_red_base = location_info:new({text = "Center Room", team = Team.kRed})
location_yellow_base = location_info:new({text = "Center Room", team = Team.kYellow})
location_green_base = location_info:new({text = "Center Room", team = Team.kGreen})

location_blue_battlements = location_info:new({text = "Battlements", team = Team.kBlue})
location_red_battlements = location_info:new({text = "Battlements", team = Team.kRed})
location_yellow_battlements = location_info:new({text = "Battlements", team = Team.kYellow})
location_green_battlements = location_info:new({text = "Battlements", team = Team.kGreen})

location_blue_entrance = location_info:new({text = "Entrance", team = Team.kBlue})
location_red_entrance = location_info:new({text = "Entrance", team = Team.kRed})
location_yellow_entrance = location_info:new({text = "Entrance", team = Team.kYellow})
location_green_entrance = location_info:new({text = "Entrance", team = Team.kGreen})

location_outside = location_info:new({text = "Outside", team = NO_TEAM})

location_blue_resupply = location_info:new({text = "Resupply", team = Team.kBlue})
location_red_resupply = location_info:new({text = "Resupply", team = Team.kRed})
location_yellow_resupply = location_info:new({text = "Resupply", team = Team.kYellow})
location_green_resupply = location_info:new({text = "Resupply", team = Team.kGreen})

location_blue_roof = location_info:new({text = "Roof", team = Team.kBlue})
location_red_roof = location_info:new({text = "Roof", team = Team.kRed})
location_yellow_roof = location_info:new({text = "Roof", team = Team.kYellow})
location_green_roof = location_info:new({text = "Roof", team = Team.kGreen})

location_blue_spawn = location_info:new({text = "Spawn Room", team = Team.kBlue})
location_red_spawn = location_info:new({text = "Spawn Room", team = Team.kRed})
location_yellow_spawn = location_info:new({text = "Spawn Room", team = Team.kYellow})
location_green_spawn = location_info:new({text = "Spawn Room", team = Team.kGreen})

location_blue_tunnel = location_info:new({text = "Tunnel", team = Team.kBlue})
location_red_tunnel = location_info:new({text = "Tunnel", team = Team.kRed})
location_yellow_tunnel = location_info:new({text = "Tunnel", team = Team.kYellow})
location_green_tunnel = location_info:new({text = "Tunnel", team = Team.kGreen})
