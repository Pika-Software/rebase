if not util.FilterText then
	function util.FilterText( str ) return str end
end

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
	local string = string

	function GM:OnChatTab( str )
		str = string.TrimRight( str )

		local LastWord
		for word in string.gmatch( str, "[^ ]+" ) do
			LastWord = word
		end

		if not LastWord then return str end

		for _, ply in ipairs( player_GetAll() ) do
			local nickname = ply:Nick()
			if #LastWord < #nickname and string.find( string.lower( nickname ), string.lower( LastWord ), 0, true) == 1 then
				return string.sub( str, 1, ( #LastWord * -1 ) - 1 ) .. nickname
			end
		end

		return str
	end

end

do

	local Msg = Msg

	function GM:ChatText(playerindex, playername, text, filter)
		if filter == "chat" then
			Msg( playername, ": ", text, "\n" )
		else
			Msg( text, "\n" )
		end

		return false
	end

end

do

	language.Add( "dead", "Dead" )
	language.Add( "team", "Team" )
	language.Add( "console", "Console" )

	local green = Color( 30, 160, 40 )
	local red = Color( 255, 30, 40 )

	local TEXT_FILTER_GAME_CONTENT = TEXT_FILTER_GAME_CONTENT
	local TEXT_FILTER_CHAT = TEXT_FILTER_CHAT

	local unpack = unpack
	local IsValid = IsValid
	local bit_band = bit.band
	local util_FilterText = util.FilterText
	local language_GetPhrase = language.GetPhrase
	local cl_chatfilters = GetConVar( "cl_chatfilters" )

	function GM:OnPlayerChat( ply, strText, isTeam, isDead )
		if not IsValid( ply ) then
			chat.AddText( language_GetPhrase( "console" ), color_white, ": ", strText )
			return true
		end

		local data = {}
		if isDead then
			data[ #data + 1 ] = red
			data[ #data + 1 ] = "*" .. language_GetPhrase( "dead" ):upper() .. "* "
		end

		if isTeam then
			data[ #data + 1 ] = green
			data[ #data + 1 ] = "(" .. language_GetPhrase( "team" ):upper() .. ") "
		end

		data[ #data + 1 ] = ply
		data[ #data + 1 ] = color_white
		data[ #data + 1 ] = ": " .. util_FilterText( strText, ( bit_band( cl_chatfilters:GetInt(), 64 ) ~= 0 ) and TEXT_FILTER_CHAT or TEXT_FILTER_GAME_CONTENT, ply )

		chat.AddText( unpack( data ) )

		return true
	end

end

do

	local white = Color( 230, 230, 230 )
	local yellow = Color( 255, 200, 0 )
	local achievements_GetName = achievements.GetName

	function GM:OnAchievementAchieved( ply, achid )
		chat.AddText( ply, white, " earned the achievement ", yellow, achievements_GetName( achid ) )
	end

end