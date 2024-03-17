
-- base_ctf.lua
-- Capture the flag gametype

-----------------------------------------------------------------------------
-- includes
-----------------------------------------------------------------------------
IncludeScript("base_teamplay");


-----------------------------------------------------------------------------
-- entities
-----------------------------------------------------------------------------

-- hudalign and hudstatusiconalign : 0 = HUD_LEFT, 1 = HUD_RIGHT, 2 = HUD_CENTERLEFT, 3 = HUD_CENTERRIGHT 
-- (pixels from the left / right of the screen / left of the center of the screen / right of center of screen,
-- AfterShock
blue_flag = baseflag:new({team = Team.kBlue,
						 modelskin = 0,
						 name = "Blue Flag",
						 hudicon = "hud_flag_blue_new.vtf",
						 hudx = 5,
						 hudy = 80,
						 hudwidth = 70,
						 hudheight = 70,
						 hudalign = 1, 
						 hudstatusicondropped = "hud_flag_dropped_blue.vtf",
						 hudstatusiconhome = "hud_flag_home_blue.vtf",
						 hudstatusiconcarried = "hud_flag_carried_blue.vtf",
						 hudstatusiconx = 60,
						 hudstatusicony = 5,
						 hudstatusiconw = 15,
						 hudstatusiconh = 15,
						 hudstatusiconalign = 2,
						 objectiveicon = true,
						 touchflags = {AllowFlags.kOnlyPlayers,AllowFlags.kRed,AllowFlags.kYellow,AllowFlags.kGreen}})

red_flag = baseflag:new({team = Team.kRed,
						 modelskin = 1,
						 name = "Red Flag",
						 hudicon = "hud_flag_red_new.vtf",
						 hudx = 5,
						 hudy = 150,
						 hudwidth = 70,
						 hudheight = 70,
						 hudalign = 1,
						 hudstatusicondropped = "hud_flag_dropped_red.vtf",
						 hudstatusiconhome = "hud_flag_home_red.vtf",
						 hudstatusiconcarried = "hud_flag_carried_red.vtf",
						 hudstatusiconx = 60,
						 hudstatusicony = 5,
						 hudstatusiconw = 15,
						 hudstatusiconh = 15,
						 hudstatusiconalign = 3,
						 objectiveicon = true,
						 touchflags = {AllowFlags.kOnlyPlayers,AllowFlags.kBlue,AllowFlags.kYellow,AllowFlags.kGreen}})
						  
yellow_flag = baseflag:new({team = Team.kYellow,
						 modelskin = 2,
						 name = "Yellow Flag",
						 hudicon = "hud_flag_yellow_new.vtf",
						 hudx = 5,
						 hudy = 220,
						 hudwidth = 70,
						 hudheight = 70,
						 hudalign = 1,
						 hudstatusicondropped = "hud_flag_dropped_yellow.vtf",
						 hudstatusiconhome = "hud_flag_home_yellow.vtf",
						 hudstatusiconcarried = "hud_flag_carried_yellow.vtf",
						 hudstatusiconx = 53,
						 hudstatusicony = 25,
						 hudstatusiconw = 15,
						 hudstatusiconh = 15,
						 hudstatusiconalign = 2,
						 objectiveicon = true,
						 touchflags = {AllowFlags.kOnlyPlayers,AllowFlags.kBlue,AllowFlags.kRed,AllowFlags.kGreen} })

green_flag = baseflag:new({team = Team.kGreen,
						 modelskin = 3,
						 name = "Green Flag",
						 hudicon = "hud_flag_green_new.vtf",
						 hudx = 5,
						 hudy = 290,
						 hudwidth = 70,
						 hudheight = 70,
						 hudalign = 1,
						 hudstatusicondropped = "hud_flag_dropped_green.vtf",
						 hudstatusiconhome = "hud_flag_home_green.vtf",
						 hudstatusiconcarried = "hud_flag_carried_green.vtf",
						 hudstatusiconx = 53,
						 hudstatusicony = 25,
						 hudstatusiconw = 15,
						 hudstatusiconh = 15,
						 hudstatusiconalign = 3,
						 objectiveicon = true,
						 touchflags = {AllowFlags.kOnlyPlayers,AllowFlags.kBlue,AllowFlags.kRed,AllowFlags.kYellow} })						  

-- red cap point
red_cap = basecap:new({team = Team.kRed,
					   item = {"blue_flag","yellow_flag","green_flag"}})

-- blue cap point					   
blue_cap = basecap:new({team = Team.kBlue,
						item = {"red_flag","yellow_flag","green_flag"}})

-- yellow cap point						
yellow_cap = basecap:new({team = Team.kYellow,
						item = {"blue_flag","red_flag","green_flag"}})

-- green cap point						
green_cap = basecap:new({team = Team.kGreen,
						item = {"blue_flag","red_flag","yellow_flag"}})

-----------------------------------------------------------------------------
-- map handlers
-----------------------------------------------------------------------------
function startup()

	SetGameDescription( "Capture the Flag" )
	
	-- set up team limits on each team
	SetPlayerLimit(Team.kBlue, 0)
	SetPlayerLimit(Team.kRed, 0)
	SetPlayerLimit(Team.kYellow, -1)
	SetPlayerLimit(Team.kGreen, -1)

	-- CTF maps generally don't have civilians,
	-- so override in map LUA file if you want 'em
	local team = GetTeam(Team.kBlue)
	team:SetClassLimit(Player.kCivilian, -1)
	team:SetClassLimit( Player.kSniper, -1 )

	team = GetTeam(Team.kRed)
	team:SetClassLimit(Player.kCivilian, -1)
	team:SetClassLimit( Player.kSniper, -1 )
end

function precache()
	-- precache sounds
	PrecacheSound("yourteam.flagstolen")
	PrecacheSound("otherteam.flagstolen")
	PrecacheSound("yourteam.flagcap")
	PrecacheSound("otherteam.flagcap")
	PrecacheSound("yourteam.drop")
	PrecacheSound("otherteam.drop")
	PrecacheSound("yourteam.flagreturn")
	PrecacheSound("otherteam.flagreturn")
end

--flaginfo runs whenever the player spawns or uses the flaginfo command.
--Right now it just refreshes the HUD items; this ensures that players who just joined the server have the right information
function flaginfo( player_entity )
	flaginfo_base(player_entity) --see base_teamplay.lua
end

function flag_think()
    local rflag = GetInfoScriptByName( "red_flag" )
    if rflag then
        local loc = rflag:GetOrigin()
        if ( loc.z < -500 and rflag:IsDropped() ) then
            -- The red flag is dropped and in a bad location.
            -- Modified copy-paste from base_flag:onreturn to get the standardized look and feel.
            -- I would have expected base_flag:Return to call base_flag:onreturn but it does not and I cannot.
            
            -- Message that the flag has been returned. 
            local team = GetTeam( Team.kRed )
            SmartTeamMessage(team, "#FF_TEAMRETURN", "#FF_OTHERTEAMRETURN", Color.kYellow, Color.kYellow)
            SmartTeamSound(team, "yourteam.flagreturn", "otherteam.flagreturn")
            SmartTeamSpeak(team, "CTF_FLAGBACK", "CTF_EFLAGBACK")
            
            -- Clean up.
            RemoveHudItemFromAll( rflag:GetName() .. "location" ) -- Remove flag location.
            rflag:Return() -- Return to spawn.
            LogLuaEvent(0, 0, "flag_returned","flag_name",rflag:GetName()); -- Log event.
            rflag:refreshStatusIcons(rflag:GetName())  -- Refresh flag-status icons
        end
    end

    local bflag = GetInfoScriptByName( "blue_flag" )    
    if bflag then
        local loc = bflag:GetOrigin()
        if ( loc.z < -500 and bflag:IsDropped() ) then 
            -- The blue flag is dropped and in a bad location.
            -- Modified copy-paste from base_flag:onreturn to get the standardized look and feel.
            -- I would have expected base_flag:Return to call base_flag:onreturn but it does not and I cannot.
            
            -- Message that the flag has been returned. 
            local team = GetTeam( Team.kBlue )
            SmartTeamMessage(team, "#FF_TEAMRETURN", "#FF_OTHERTEAMRETURN", Color.kYellow, Color.kYellow)
            SmartTeamSound(team, "yourteam.flagreturn", "otherteam.flagreturn")
            SmartTeamSpeak(team, "CTF_FLAGBACK", "CTF_EFLAGBACK")
            
            -- Clean up.
            RemoveHudItemFromAll( bflag:GetName() .. "location" ) -- Remove flag location.
            bflag:Return() -- Return to spawn.
            LogLuaEvent(0, 0, "flag_returned","flag_name",bflag:GetName()); -- Log event.
            bflag:refreshStatusIcons(bflag:GetName())  -- Refresh flag-status icons
        end
    end
end

-- Schedule a repeating flag check. If the flag is in the pit then it should be returned.
    AddScheduleRepeating( "flag loop", 0.2, flag_think )