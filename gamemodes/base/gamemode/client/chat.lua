function GM:ChatTextChanged( text )
end

function GM:StartChat( teamsay )
	return false
end

function GM:FinishChat()
end

do

	local player_GetAll = player.GetAll
	local ipairs = ipairs

	function GM:OnChatTab(str)
		str = str:TrimRight()

		local LastWord
		for word in str:gmatch("[^ ]+") do
			LastWord = word
		end

		if (LastWord == nil) then return str end
		for num, ply in ipairs( player_GetAll() ) do
			local nickname = ply:Nick()
			if (LastWord:len() < nickname:len() and nickname:lower():find(LastWord:lower(), 0, true) == 1) then
				return str:sub(1, (LastWord:len() * -1) - 1) .. nickname
			end
		end

		return str
	end

end

do
	local Msg = Msg
	function GM:ChatText(playerindex, playername, text, filter)
		if (filter == "chat") then
			Msg(playername, ": ", text, "\n")
		else
			Msg(text, "\n")
		end

		return false
	end
end

do

	language.Add( "dead", "Dead" )
	language.Add( "team", "Team" )
	language.Add( "console", "Console" )

	local red = Color( 255, 30, 40 )
	local green = Color( 30, 160, 40 )

	local TEXT_FILTER_CHAT = TEXT_FILTER_CHAT
	local TEXT_FILTER_GAME_CONTENT = TEXT_FILTER_GAME_CONTENT

	local IsValid = IsValid
	local hook_Run = hook.Run
	local bit_band = bit.band
	local util_FilterText = util.FilterText
	local language_GetPhrase = language.GetPhrase

	local chat_filter = cvars.Number( "cl_chatfilters", 0 )
	cvars.AddChangeCallback("cl_chatfilters", function( name, old, new )
		chat_filter = tonumber( new )
	end)

	function GM:OnPlayerChat( ply, strText, isTeam, isDead, ... )
		local pre = hook_Run( "PrePlayerChat", ply, strText, isTeam, isDead, ... )
		if (pre ~= nil) then
			local post = hook_Run( "PostPlayerChat", ply, strText, isTeam, isDead, ... )
			if (post ~= nil) then
				return post
			end

			return pre
		end

		if IsValid( ply ) then
			local data = {}
			if (isDead) then
				table.insert( data, red )
				table.insert( data, "*" .. language_GetPhrase( "dead" ):upper() .. "* " )
			end

			if (isTeam) then
				table.insert( data, green )
				table.insert( data, "(" .. language_GetPhrase( "team" ):upper() .. ") " )
			end

			table.insert( data, ply )
			table.insert( data, color_white )
			table.insert( data, ": " .. util.FilterText( strText, (bit.band( chat_filter, 64 ) ~= 0) and TEXT_FILTER_CHAT or TEXT_FILTER_GAME_CONTENT, ply ) )

			chat.AddText( unpack( data ) )
		else
			chat.AddText( language_GetPhrase( "console" ), color_white, ": ", strText )
		end

		local post = hook_Run( "PostPlayerChat", ply, strText, isTeam, isDead, ... )
		if (post ~= nil) then
			return post
		end

		return true
	end

end

do

	local white = Color( 230, 230, 230 )
	local yellow = Color( 255, 200, 0 )
	local achievements_GetName = achievements.GetName

	function GM:OnAchievementAchieved(ply, achid)
		chat.AddText( ply, white, " earned the achievement ", yellow, achievements_GetName( achid ) )
	end

end

if (util.FilterText == nil) then
	function util.FilterText( str )
		return str
	end
end