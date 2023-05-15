-- INFORMATION
	-- StuffAccounts v1.3f
	-- Script was written by Sirexer
	-- You can edit it for your server
	-- Download original script here: https://mb.srb2.org/addons/stuffaccounts.4219/
-- What does this script do?
	-- Allows players to create an account;
	-- Can automatically register players;
	-- Players can keep their stuff even if the server has been restarted;
	-- Returns admin to players if they were admins;
	-- Retains a shield after completing a level;
	-- Servers can record when an account is created or a password is changed.
-- Console commands:
	-- Server commands.
	-- "do_autoreg" - automatically registers accounts for players;
	-- "do_stufflog" - writes logs when a player saves their items;
	-- "do_accountlog" - writes logs when a player creates or changes a password;
	-- Player commands.
	-- "ac_help" - show instruction for player;
	-- "ac_register" - registers on the server;
	-- "ac_login" - Login to account;
	-- "ac_changepass" - Changes password

-- Change this value so that players don't lose their passwords.
-- NOTE: Do not use symbols such as / \ | < > * : ? ^ " .
local stuff_servername = "DreamUniverse"
-- Folder where accounts will be saved.
local folderstuff = "StuffAccounts/Accounts/"
-- The folder in which the player saves the username and password for HIMSELF.
local client_folderstuff = "client/StuffAccounts/"..stuff_servername..".dat"

local savingplayerstuff = nil
local savingnodestuff = nil
local loadingplayerstuff = nil
local loadingnodestuff = nil

local function PlayerNodes(pname)
	local N = tonumber(pname)
	if N ~= nil and N >= 0 and N < 32 then
		for player in players.iterate do
			if #player == N then
			return player
			end
		end
	end
	for player in players.iterate do
		if string.find(string.lower(player.name), string.lower(pname)) then
			return player
		end
	end
	return nil
end

local function FindPlayer(player, pname)
	local player2 = PlayerNodes(pname)
	if not player2 then
		CONS_Printf(player, "No one here has that name.")
	end
	return player2
end

local function getstuffname(cmd_string)
	local string_1 = string.gsub(cmd_string, "/", "")
	local string_2 = string.gsub(string_1, "\\", "")
	local string_3 = string.gsub(string_2, "*", "")
	local string_4 = string.gsub(string_3, ":", "")
	local string_5 = string.gsub(string_4, "\"", "")
	local string_6 = string.gsub(string_5, "?", "")
	local string_7 = string.gsub(string_6, "|", "")
	local string_8 = string.gsub(string_7, "<", "")
	local stuffname = string.gsub(string_8, ">", "")
	return stuffname
end

local function GetRandomNumber()
	local pass_part01 = 1234
	local pass_part02 = 5678
	local pass_full = "12345678"
	pass_part01 = P_RandomRange(1000, 9999)
	pass_part02 = P_RandomRange(1000, 9999)
	pass_full = (tostring(pass_part01..pass_part02))
	if pass_full
		return pass_full
	end
end

local function IsUsernameLogged(username)
	local check_user = nil
	if username == nil
		return
	end
	for player in players.iterate do
		if player.stuffname == username
			check_user = true
			return check_user
		end
	end
end

local function ExitIfNoPlayerOnTheSP()
	if G_IsSpecialStage(gamemap)
		for player in players.iterate do
			if player
				return
			end
		end
		if leveltime > 0
			print("Skip the Special Stage because there are no players.")
			G_ExitLevel()
		end
	end
end

local OtherStuff = {}
local function SaveOtherStuff(stuff, player)
	-- Team
	if G_GametypeHasTeams() then stuff.team = player.ctfteam end
	-- Spectator
	stuff.spectator = player.spectator
	if player.spectator == true then return end
	-- Player completed the level
	if (player.pflags & PF_FINISHED)
		stuff.fineshed = PF_FINISHED
	end
	-- Player's time when he completed the level(does work without DU_Script.lua)
	if player.completiontime
		stuff.completiontime = player.completiontime
	end
	-- Star post
	if G_PlatformGametype()
		if player.starpostnum != 0
			stuff.starposted = true
			stuff.starpostx = player.starpostx
			stuff.starposty = player.starposty
			stuff.starpostz = player.starpostz
			stuff.starpostnum = player.starpostnum
			stuff.starposttime = player.starposttime
			stuff.starpostangle = player.starpostangle
			stuff.starpostscale = player.starpostscale
		end
	end
	-- Rings
	stuff.rings = player.rings
	-- Invincibility
	stuff.invincibility = player.powers[pw_invulnerability]
	-- Super Shoes
	stuff.speed = player.powers[pw_sneakers]
	-- Weapon rings
	stuff.weapons = player.ringweapons
	stuff.infinity = player.powers[pw_infinityring]
	stuff.automatic = player.powers[pw_automaticring]
	stuff.bounce = player.powers[pw_bouncering]
	stuff.scatter = player.powers[pw_scatterring]
	stuff.grenade = player.powers[pw_grenadering]
	stuff.explosion = player.powers[pw_explosionring]
	stuff.rail = player.powers[pw_railring]
	-- Times hit
	stuff.timeshit = player.timeshit
	-- Competition
	if gametype == GT_COMPETITION
		stuff.numboxes = player.numboxes
		stuff.totalring = player.totalring
		stuff.realtime = player.realtime
	end
	-- Laps
	if gametype == GT_RACE then stuff.laps = player.laps end
end

local function LoadOtherStuff(stuff, player)
	-- Team
	if G_GametypeHasTeams() then player.ctfteam = stuff.team end
	-- Spectator
	if player.spectator == true and stuff.spectator == false
		player.spectator = false
		G_DoReborn(#player)
	elseif stuff.spectator == true
		return
	end
	-- Player completed the level
	if stuff.fineshed and player.isafk == false and player.afk == false
		player.pflags = $ + PF_FINISHED
	end
	-- Player's time when he completed the level
	if stuff.completiontime
		player.completiontime = stuff.completiontime
	end
	-- Star post
	if G_PlatformGametype()
		if stuff.starposted == true
			player.starpostx = stuff.starpostx
			player.starposty = stuff.starposty
			player.starpostz = stuff.starpostz
			player.starpostnum = stuff.starpostnum
			player.starposttime = stuff.starposttime
			player.starpostangle = stuff.starpostangle
			player.starpostscale = stuff.starpostscale
			P_TeleportMove(player.mo, player.starpostx*FRACUNIT, player.starposty*FRACUNIT, player.starpostz*FRACUNIT)
			player.mo.angle = player.starpostangle
			player.mo.scale = player.starpostscale
		end
	end
	-- Rings
	player.rings = stuff.rings
	-- Invincibility
	player.powers[pw_invulnerability] = $ + stuff.invincibility
	-- Super Shoes
	player.powers[pw_sneakers] = $ + stuff.speed
	-- Weapons
	player.ringweapons = $ | stuff.weapons
	player.powers[pw_infinityring] = $ + stuff.infinity
	player.powers[pw_automaticring] = $ + stuff.automatic
	player.powers[pw_bouncering] = $ + stuff.bounce
	player.powers[pw_scatterring] = $ + stuff.scatter
	player.powers[pw_grenadering] = $ + stuff.grenade
	player.powers[pw_explosionring] = $ + stuff.explosion
	player.powers[pw_railring] = $ + stuff.rail
	-- Times hit
	player.timeshit = stuff.timeshit
	-- Competition
	if gametype == GT_COMPETITION
		player.numboxes = stuff.numboxes
		player.totalring = stuff.totalring
		player.realtime = stuff.realtime
	end
	-- Laps
	if gametype == GT_RACE then player.laps = stuff.laps end
end

rawset(_G, "cv_autoreg", CV_RegisterVar({
	name = "do_autoreg",
	defaultvalue = "Off",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff
}))

rawset(_G, "cv_dologstuff", CV_RegisterVar({
	name = "do_stufflog",
	defaultvalue = "Off",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff
}))

rawset(_G, "cv_dologaccount", CV_RegisterVar({
	name = "do_accountlog",
	defaultvalue = "Off",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff
}))

rawset(_G, "cv_setadmin", CV_RegisterVar({
	name = "do_setadmin",
	defaultvalue = "Off",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff
}))

COM_AddCommand("s_clearplayerfromstuff", function()
	for player in players.iterate do
		if	player.passwordstuff != nil
			player.passwordstuff = nil
		end
		if player.changingpass != nil
			player.changingpass = nil
		end
	end
	savingplayerstuff = nil
	savingnodestuff = nil
end, 1)

COM_AddCommand("l_clearplayerfromstuff", function()
	for player in players.iterate do
		if	player.passwordstuff != nil
			player.passwordstuff = nil
		end
		if player.changingpass != nil
			player.changingpass = nil
		end
	end
	loadingplayerstuff = nil
	loadingnodestuff = nil
end, 1)

COM_AddCommand("setusername", function(player, pname, username, usererror, password)
	if player != server
		if server.isdedicated != true
			CONS_Printf(player, "Remote admin can't use this command.")
			return
		end
	end
	if not pname
		return
	end
	local player2 = FindPlayer(player, pname)
	if player2 then
		if usererror == "0"
			player2.stuffname = string.lower(username)
			player2.hud_countload = 5*TICRATE
			COM_BufInsertText(player2, "io_loginpass write "..password)
			CONS_Printf(player2, "You are logged in as "..username..".")
		elseif usererror == "newuser"
			player2.newuser = true
			player2.stuffname = string.lower(username)
			COM_BufInsertText(player2, "io_loginpass write "..password)
			CONS_Printf(player2, "You are logged in as "..username..".")
		elseif usererror == "1"
			CONS_Printf(player2, "Account with this username is already taken.")
		elseif usererror == "2"
			CONS_Printf(player2, "This account does not exist.")
		elseif usererror == "3"
			CONS_Printf(player2, "Invalid login or password.")
		elseif usererror == "4"
			CONS_Printf(player2, "This username is currently being used by another player.")
		end
	end
end, 1)

COM_AddCommand("setstuff", function(player, pname, arg1, arg2, arg3, arg4)
	if player != server
		if server.isdedicated != true
			CONS_Printf(player, "Remote admin can't use this command.")
			return
		end
	end
	if pname == nil
		return
	end
	local player2 = FindPlayer(player, pname)
	if player2 then
	
		if arg1 then
			player2.score = arg1
		end
		
		if arg2 then
			player2.lives = arg2
		end
		
		if arg3 then
			if not G_IsSpecialStage(gamemap)
				player2.powers[pw_shield] = arg3
				P_SpawnShieldOrb(player2)
			elseif G_IsSpecialStage(gamemap)
				player2.saveshield = arg3
			end
		end
		
		if arg4 then
			if arg4 != "none"
				local N = tonumber(arg4)
				if N ~= nil then
					player2.skipscrap = N
				end
			end
		end
		
	end
end, 1)

COM_AddCommand("io_loginpass", function(player, arg, password)
	local txt_user = nil
	local txt_pass = nil
	local txt_login = nil
	if arg == "read"
		local login = io.openlocal(client_folderstuff, "r")
		if login
			txt_login = login:read("*a") or $
			login:close()
			COM_BufInsertText(player, txt_login)
			return
		end
	end
	if player.stuffname
		txt_user = player.stuffname
	end
	if password
		txt_pass = password
	end
	if not txt_user or not txt_pass
		return
	end
	if arg == "write"
		local login = io.openlocal(client_folderstuff, "w")
		login:write("ac_login \""..txt_user.."\" \""..txt_pass.."\"")
		login:close()
	end
end, COM_LOCAL)

COM_AddCommand("loadnamestuff", function(player, password)
	if server != player
		CONS_Printf(player, "This command is used only for the server")
		return
	end
	if server == player
		if loadingplayerstuff != nil
			-- locals variable.
			local ps_password = "none"
			local ps_s = loadingplayerstuff.score
			local ps_l = loadingplayerstuff.lives
			local ps_sh = loadingplayerstuff.powers[pw_shield]
			local ps_scrap = "none"
			local ps_admin = "false"
			local check_user = IsUsernameLogged(loadingplayerstuff.username)
			
			if password // log in account
				local loginpassword = io.openlocal(folderstuff..loadingplayerstuff.username.."/password.dat", "r")
				if loginpassword
					ps_password = loginpassword:read("*a") or $
					loginpassword:close()
					if ps_password == password
						if check_user == nil
							loadingplayerstuff.stuffname = loadingplayerstuff.username
							COM_BufInsertText(server, "setusername "..loadingnodestuff.." \""..loadingplayerstuff.username.."\" 0 "..password)
						else
							COM_BufInsertText(server, "setusername "..loadingnodestuff.." non 4")
						end
					elseif ps_password != password
						COM_BufInsertText(server, "setusername "..loadingnodestuff.." non 3")
					end
				elseif not loginpassword
					COM_BufInsertText(server, "setusername "..loadingnodestuff.." non 2")
				end
			end
			
			if loadingplayerstuff.stuffname -- This load stuff for the player.
				if gametype == GT_COOP
					-- Load score.
					local scorestuff = io.openlocal(folderstuff..loadingplayerstuff.stuffname.."/score.dat", "r")
					if scorestuff
						ps_s = scorestuff:read("*a") or $
						scorestuff:close()
					end
					-- Load lives.
					local livesstuff = io.openlocal(folderstuff..loadingplayerstuff.stuffname.."/lives.dat", "r")
					if livesstuff
						ps_l = livesstuff:read("*a") or $
						livesstuff:close()
					end
					-- Load shield.
					local shieldstuff = io.openlocal(folderstuff..loadingplayerstuff.stuffname.."/shield.dat", "r")
					if shieldstuff
						ps_sh = shieldstuff:read("*a") or $
						shieldstuff:close()
					end
					-- Load scrap for skip.
					local scrapstuff = io.openlocal(folderstuff..loadingplayerstuff.stuffname.."/skipscrap.dat", "r")
					if scrapstuff
						ps_scrap = scrapstuff:read("*n") or $
						scrapstuff:close()
					else
						ps_scrap = "none"
					end
				end
				if cv_setadmin.value == 1
					-- Promote the player, if the player was admin on the server.
					local adminstuff = io.openlocal(folderstuff..loadingplayerstuff.stuffname.."/admin.dat", "r")
					if adminstuff
						ps_admin = adminstuff:read("*a") or $
						adminstuff:close()
						if ps_admin == "true"
							COM_BufInsertText(server, "promote "..loadingnodestuff)
						end
					end
				end
				-- Set stuff
				COM_BufInsertText(server, "setstuff "..loadingnodestuff.." "..ps_s.." "..ps_l.." "..ps_sh.." "..ps_scrap)
			end
			COM_BufInsertText(server, "l_clearplayerfromstuff")
		end
	end
end, COM_LOCAL)

COM_AddCommand("savenamestuff", function(player, password)
	if server != player
		CONS_Printf(player, "This command is used only for the server")
		return
	end
	if server == player
		if savingplayerstuff != nil
			-- Do a log when the player saves things.
			if cv_dologstuff.value == 1
				local log_stuff = io.openlocal(folderstuff.."/log_stuff.txt", "a+")
				log_stuff:write("Player name: "..savingplayerstuff.name.." Score: "..savingplayerstuff.score.." Lives: "..savingplayerstuff.lives.." Shield: "..savingplayerstuff.saveshield.."\n")
				log_stuff:close()
			end
			if password
				if savingplayerstuff.stuffname == nil -- Registers account
					local check_loginpassword = io.openlocal(folderstuff..savingplayerstuff.username.."/password.dat", "r")
					if check_loginpassword
						check_loginpassword:close()
						COM_BufInsertText(server, "setusername "..savingnodestuff.." non 1")
					end
					if not check_loginpassword
						local loginpassword = io.openlocal(folderstuff..savingplayerstuff.username.."/password.dat", "w")
						if cv_dologaccount.value == 1
							local log_account = io.openlocal(folderstuff.."/log_account.txt", "a+")
							log_account:write(savingplayerstuff.name.." created an account with "..savingplayerstuff.username.." username\n")
							log_account:close()
						end
						CONS_Printf(server, "Created account for "..savingplayerstuff.username)
						loginpassword:write(password)
						loginpassword:close()
						COM_BufInsertText(server, "setusername "..savingnodestuff.." \""..savingplayerstuff.username.."\" newuser "..password)
					end
				end
				if savingplayerstuff.stuffname != nil -- Changes password
					local changepass = io.openlocal(folderstuff..savingplayerstuff.stuffname.."/password.dat", "w")
					changepass:write(password)
					changepass:close()
					if cv_dologaccount.value == 1
						local log_account = io.openlocal(folderstuff.."/log_account.txt", "a+")
						log_account:write(savingplayerstuff.name.." changed password for "..savingplayerstuff.username.." username\n")
						log_account:close()
					end
					CONS_Printf(server, "Changed password for "..savingplayerstuff.username)
				end
			end
			-- This save stuff of the player.
			if savingplayerstuff.stuffname
				if gametype == GT_COOP
					-- Save rings
					local scorestuff = io.openlocal(folderstuff..savingplayerstuff.stuffname.."/score.dat", "w")
					scorestuff:write(savingplayerstuff.score)
					scorestuff:close()
					-- Save lives
					local livesstuff = io.openlocal(folderstuff..savingplayerstuff.stuffname.."/lives.dat", "w")
					livesstuff:write(savingplayerstuff.lives)
					livesstuff:close()
					-- Save shield
					local shieldstuff = io.openlocal(folderstuff..savingplayerstuff.stuffname.."/shield.dat", "w")
					shieldstuff:write(savingplayerstuff.saveshield)
					shieldstuff:close()
					-- Save scrap for skip
					if savingplayerstuff.skipscrap
						local shieldstuff = io.openlocal(folderstuff..savingplayerstuff.stuffname.."/skipscrap.dat", "w")
						shieldstuff:write(savingplayerstuff.skipscrap)
						shieldstuff:close()
					end
				end
				-- Save admin
				if cv_setadmin.value == 1
					if IsPlayerAdmin(savingplayerstuff)
						local adminstuff = io.openlocal(folderstuff..savingplayerstuff.stuffname.."/admin.dat", "w")
						adminstuff:write("true")
						adminstuff:close()
					else
						local adminstuff = io.openlocal(folderstuff..savingplayerstuff.stuffname.."/admin.dat", "w")
						adminstuff:write("false")
						adminstuff:close()
					end
				end
				
			end
			COM_BufInsertText(server, "s_clearplayerfromstuff")
		end
	end
end, COM_LOCAL)

COM_AddCommand("savestuff", function(player)
	if player == server
		if server.isdedicated == true
			CONS_Printf(player, "Join to the game to use this command.")
			return
		end
	end
	if player.cansavestuff == true 
		if savingplayerstuff == nil
			savingplayerstuff = player
			COM_BufInsertText(server, "savenamestuff")
		else
			COM_BufInsertText(player, "echo saving...; wait 35; savestuff")
		end
		player.cansavestuff = nil
	end
end)

COM_AddCommand("ac_login", function(player, username, password)
	if player == server
		if server.isdedicated == true
			CONS_Printf(player, "Join to the game to use this command.")
			return
		end
	end
	if player.stuffname != nil
		CONS_Printf(player, "You are already logged in to the server.")
		return
	end
	if player.stuffname == nil
		if username == nil or password == nil
			CONS_Printf(player, "ac_login <username> <password>")
			return
		end
		if username != getstuffname(username)
			CONS_Printf(player, "Do not use symbols such as / \ | < > * : ? ^ . \"")
			return
		end
		if username != string.gsub(username, " ", "")
			CONS_Printf(player, "Don't use spaces in username!")
			return
		end
		if password != string.gsub(password, " ", "")
			CONS_Printf(player, "Don't use spaces in password!")
			return
		end
		if loadingplayerstuff == nil
			player.username = username
			loadingplayerstuff = player
			loadingnodestuff = #player
			COM_BufInsertText(server, "loadnamestuff "..password)
		else
			COM_BufInsertText(player, "wait 35; ac_login "..username.." "..password)
		end
	end
end)

COM_AddCommand("ac_register", function(player, username, password)
	if player == server
		if server.isdedicated == true
			CONS_Printf(player, "Join to the game to use this command.")
			return
		end
	end
	if player.stuffname == nil
		if username == nil or password == nil
			CONS_Printf(player, "ac_register <username> <password>")
			if not player.getwarn
				CONS_Printf(player, "\x82Warning:\x80 Do not use passwords that are compatible with your account passwords (steam, twitter, facebook adn etc). The server host has access to your password")
				player.getwarn = true
			end
			return
		end
		if username != getstuffname(username)
			CONS_Printf(player, "Do not use symbols such as / \ | < > * : ? ^ . \"")
			if not player.getwarn
				CONS_Printf(player, "\x82Warning:\x80 Do not use passwords that are compatible with your account passwords (steam, twitter, facebook adn etc). The server host has access to your password")
				player.getwarn = true
			end
			return
		end
		if username != string.gsub(username, " ", "")
			CONS_Printf(player, "Don't use spaces in username!")
			if not player.getwarn
				CONS_Printf(player, "\x82Warning:\x80 Do not use passwords that are compatible with your account passwords (steam, twitter, facebook adn etc). The server host has access to your password")
				player.getwarn = true
			end
			return
		end
		if password != string.gsub(password, " ", "")
			CONS_Printf(player, "Don't use spaces in passwords!")
			if not player.getwarn
				CONS_Printf(player, "\x82Warning:\x80 Do not use passwords that are compatible with your account passwords (steam, twitter, facebook adn etc). The server host has access to your password")
				player.getwarn = true
			end
			return
		end
		if password == "random"
			password = GetRandomNumber()
		end
		if savingplayerstuff == nil
			player.username = string.lower(username)
			savingplayerstuff = player
			savingnodestuff = #player
			COM_BufInsertText(server, "savenamestuff "..password)
		else
			COM_BufInsertText(player, "wait 35; ac_register "..username.." "..password)
		end
	else
		CONS_Printf(player, "You are already logged in to the server.")
	end
end)

COM_AddCommand("ac_changepass", function(player, password)
	if player == server
		if server.isdedicated == true
			CONS_Printf(player, "Join to the game to use this command.")
			return
		end
	end
	if player.stuffname == nil
		CONS_Printf(player, "To change your password, you must first log in to your account.")
		return
	end
	if not password
		CONS_Printf(player, "ac_changepass <new_password>")
		return
	end
	if password != string.gsub(password, " ", "")
		CONS_Printf(player, "Don't use spaces in passwords!")
		return
	end
	if savingplayerstuff == nil
		if player.delaychange != true
			savingplayerstuff = player
			savingnodestuff = #player
			player.delaychange = true
			COM_BufInsertText(player2, "io_loginpass write "..password)
			CONS_Printf(player, "Password changed successfully!")
			COM_BufInsertText(server, "savenamestuff "..password)
		else
			CONS_Printf(player, "Don't change your password so often. Wait a few minutes.")
		end
	else
		COM_BufInsertText(player, "wait 35; ac_changepass "..password)
	end
end)

COM_AddCommand("ac_help", function(player)
	CONS_Printf(player, "\x87StuffAccounts\x80. Save your stuff!")
	CONS_Printf(player, "If you don't have an account on this server, use ac_register.")
	CONS_Printf(player, "\x8b".."Examples:")
	CONS_Printf(player, "ac_register milesprower777 Hi32!tia")
	CONS_Printf(player, "An account will be registered with username \"milesprower777\" and password \"Hi32!tia\"")
	CONS_Printf(player, "\x82NOTE:".."\x80".."Do not use your website passwords! Your password is stored on the host computer, not encrypted and it can be seen by the server host.")
	CONS_Printf(player, "I recommend using a random password.")
	CONS_Printf(player, "ac_register milesprower777 random")
	CONS_Printf(player, "An account will be registered with username \"milesprower777\" and random password")
	CONS_Printf(player, "If you have an account on this server, use ac_login.")
	CONS_Printf(player, "\x8b".."Example: ac_login <username> <password>")
	CONS_Printf(player, "If you want to change your password use ac_changepass")
	CONS_Printf(player, "\x8b".."Example: ac_changepass <new_password>")
end, COM_LOCAL)
	
addHook("MapLoad", function()
	for player in players.iterate do
		if G_IsSpecialStage(gamemap) then return end
		if (player.spectator) then return end
		if player.saveshield
			player.powers[pw_shield] = player.saveshield
			P_SpawnShieldOrb(player)
		end
		if player.delaychange
			player.delaychange = nil
		end
		if player.returnscore
			if player.score == 0
				player.score = player.returnscore
			end
		end
		player.starposted = false
	end
	OtherStuff = {}
end)

addHook("ThinkFrame", do
	ExitIfNoPlayerOnTheSP()
	if savingplayerstuff
		savingplayerstuff = nil
		savingnodestuff = nil
	end
	if loadingplayerstuff
		loadingplayerstuff = nil
		loadingnodestuff = nil
	end
	for player in players.iterate do
		if leveltime > 35
			if not G_IsSpecialStage(gamemap) and leveltime > 0 and not player.exiting and not player.spectator
				player.saveshield = player.powers[pw_shield]
			end
			if player.score > 100000
				player.returnscore = (player.score-100000)
			end
		end
		if (player.saveshield == nil)
			player.saveshield = 0
		end
		if player.stuffname == nil
			if player.delay_stuffload == nil
				player.hud_countload = 0
				player.delay_stuffload = 3*TICRATE
			end
			if player.delay_stuffload != 0
				player.delay_stuffload = $ - 1
			end
			if player.delay_stuffload == 0
				if cv_autoreg.value == 1
					if player.getautoacc != true
						if player.speed > 5
							local getusername = getstuffname(player.name)
							COM_BufInsertText(player, "ac_register "..(string.gsub(getusername, " ", "")).."_"..GetRandomNumber().." random")
							player.getautoacc = true
						end
					end
				end
			end
			if player.stuffloaded != true
				if player.delay_stuffload <= 2*TICRATE
					COM_BufInsertText(player, "io_loginpass read")
					player.stuffloaded = true
				end
			end
		end
		if player.stuffname != nil
			if OtherStuff[player.stuffname]
				if not player.stuffed
					LoadOtherStuff(OtherStuff[player.stuffname], player)
					player.stuffed = true
				end
				if player.stuffed
					SaveOtherStuff(OtherStuff[player.stuffname], player)
				end
			else
				OtherStuff[player.stuffname] = {}
				player.stuffed = true
			end
			if player.hud_countload != nil and player.hud_countload > 0 
				player.hud_countload = $ - 1
			end
			if player.hud_countsave != nil and player.hud_countsave > 0 
				player.hud_countsave = $ - 1
				if player.hud_st_count > 0
					player.hud_st_count = $ - 1
				else
					player.hud_st_count = 18
				end
			end
			if player.stuffsave == nil
				player.stuffsave = 30*TICRATE
				player.hud_st_count = 10
			else
				if player.stuffsave == 0
					player.cansavestuff = true
					COM_BufInsertText(player, "savestuff")
					player.hud_countsave = 2*TICRATE
					player.stuffsave = 30*TICRATE
				else
					player.stuffsave = $ - 1
				end
			end
		end
	end
end)

addHook("NetVars", function(n)
	savingplayerstuff = n($)
	savingnodestuff = n($)
	loadingplayerstuff = n($)
	loadingnodestuff = n($)
	OtherStuff = n($)
end)

local function AccountStuff_Game(v) local player = displayplayer
	local hud_savestuff = nil
	local hud_countsave = 0
	local hus_transicon = V_SNAPTORIGHT|V_SNAPTOBOTTOM|V_ALLOWLOWERCASE
	if player.hud_st_count == 10
		hus_transicon = V_SNAPTORIGHT|V_SNAPTOBOTTOM|V_ALLOWLOWERCASE|V_90TRANS
	elseif player.hud_st_count == 9 or player.hud_st_count == 11
		hus_transicon = V_SNAPTORIGHT|V_SNAPTOBOTTOM|V_ALLOWLOWERCASE|V_80TRANS
	elseif player.hud_st_count == 8 or player.hud_st_count == 12
		hus_transicon = V_SNAPTORIGHT|V_SNAPTOBOTTOM|V_ALLOWLOWERCASE|V_70TRANS
	elseif player.hud_st_count == 7 or player.hud_st_count == 13
		hus_transicon = V_SNAPTORIGHT|V_SNAPTOBOTTOM|V_ALLOWLOWERCASE|V_60TRANS
	elseif player.hud_st_count == 6 or player.hud_st_count == 14
		hus_transicon = V_SNAPTORIGHT|V_SNAPTOBOTTOM|V_ALLOWLOWERCASE|V_50TRANS
	elseif player.hud_st_count == 5 or player.hud_st_count == 15
		hus_transicon = V_SNAPTORIGHT|V_SNAPTOBOTTOM|V_ALLOWLOWERCASE|V_40TRANS
	elseif player.hud_st_count == 4 or player.hud_st_count == 16
		hus_transicon = V_SNAPTORIGHT|V_SNAPTOBOTTOM|V_ALLOWLOWERCASE|V_30TRANS
	elseif player.hud_st_count == 3 or player.hud_st_count == 17
		hus_transicon = V_SNAPTORIGHT|V_SNAPTOBOTTOM|V_ALLOWLOWERCASE|V_20TRANS
	elseif player.hud_st_count == 2 or player.hud_st_count == 18
		hus_transicon = V_SNAPTORIGHT|V_SNAPTOBOTTOM|V_ALLOWLOWERCASE|V_10TRANS
	elseif player.hud_st_count == 1
		hus_transicon = V_SNAPTORIGHT|V_SNAPTOBOTTOM|V_ALLOWLOWERCASE
	elseif player.hud_st_count == 0
		hus_transicon = V_SNAPTORIGHT|V_SNAPTOBOTTOM|V_ALLOWLOWERCASE
	end
	if player.stuffname == nil
		if player.delay_stuffload == 0
			v.drawString(0, 194, (tostring("\x85".."Register or login to save your items! use command ac_help for instruction.")), V_ALLOWLOWERCASE|V_SNAPTOLEFT|V_SNAPTOBOTTOM, "small")
		else
			v.drawString(0, 194, (tostring("\x82".."Signing in...")), V_ALLOWLOWERCASE|V_SNAPTOLEFT|V_SNAPTOBOTTOM, "small")
		end
	end
	if player.newuser != true
		if player.hud_countload != nil and player.hud_countload > 0
			v.drawString(0, 194, (tostring("\x83".."Your stuff have been given.")), V_30TRANS|V_ALLOWLOWERCASE|V_SNAPTOLEFT|V_SNAPTOBOTTOM, "small")
		end
	end
	if player.hud_countsave != nil and player.hud_countsave > 0
		v.drawScaled(307*FRACUNIT, 150*FRACUNIT, 45056, v.cachePatch("M_FSAVE"), V_SNAPTORIGHT|V_SNAPTOBOTTOM|V_ALLOWLOWERCASE|V_30TRANS)
		v.drawScaled(307*FRACUNIT, 150*FRACUNIT, 45056, v.cachePatch("M_FLOAD"), hus_transicon)
		//v.drawString(0, 194, (tostring("\x83".."Saving your stuff...")), V_30TRANS|V_ALLOWLOWERCASE|V_SNAPTOLEFT|V_SNAPTOBOTTOM, "small")
	end
end
hud.add(AccountStuff_Game)

local function AccountStuff_scores(v) local player = displayplayer
	if player.stuffname == nil
		v.drawString(16, 0, ("\x84Username:\x85 without an account."), V_ALLOWLOWERCASE, "thin")
	else
		v.drawString(16, 0, ("\x84Username:\x8b "..player.stuffname), V_ALLOWLOWERCASE, "thin")
	end
end
hud.add(AccountStuff_scores,"scores")
