local FormattedToken = "Bot "..Config.DiscordToken

function DiscordRequest(method, endpoint, jsondata)
    local data = nil
    PerformHttpRequest("https://discordapp.com/api/"..endpoint, function(errorCode, resultData, resultHeaders)
		data = {data=resultData, code=errorCode, headers=resultHeaders}
    end, method, #jsondata > 0 and json.encode(jsondata) or "", {["Content-Type"] = "application/json", ["Authorization"] = FormattedToken})

    while data == nil do
        Citizen.Wait(0)
    end
	
    return data
end

function GetRoles(user)
	local discordId = nil
	for _, id in ipairs(GetPlayerIdentifiers(user)) do
		if string.match(id, "discord:") then
			discordId = string.gsub(id, "discord:", "")
			print("Encontrado discord id: "..discordId)
			break
		end
	end

	if discordId then
		local endpoint = ("guilds/%s/members/%s"):format(Config.GuildId, discordId)
		local member = DiscordRequest("GET", endpoint, {})
		if member.code == 200 then
			local data = json.decode(member.data)
			local roles = data.roles
			local found = true
			return roles
		else
			print("Ocorreu um erro, talvez eles não estejam na discórdia? Erro: "..member.data)
			return false
		end
	else
		print("missing identifier")
		return false
	end
end

function IsRolePresent(user, role)
	local discordId = nil
	for _, id in ipairs(GetPlayerIdentifiers(user)) do
		if string.match(id, "discord:") then
			discordId = string.gsub(id, "discord:", "")
			print("Encontrado discord id: "..discordId)
			break
		end
	end

	local theRole = nil
	if type(role) == "number" then
		theRole = tostring(role)
	else
		theRole = Config.Roles[role].id
	end

	if discordId then
		local endpoint = ("guilds/%s/members/%s"):format(Config.GuildId, discordId)
		local member = DiscordRequest("GET", endpoint, {})
		if member.code == 200 then
			local data = json.decode(member.data)
			local roles = data.roles
			local found = true
			for i=1, #roles do
				if roles[i] == theRole then
					print("Cargo encontrado")
					return true
				end
			end
			print("Não encontrado!")
			return false
		else
			print("Ocorreu um erro, talvez eles não estejam na discórdia? Erro: "..member.data)
			return false
		end
	else
		print("missing identifier")
		return false
	end
end

RegisterNetEvent('discord_perms:FetchRoles')
AddEventHandler('discord_perms:FetchRoles', function()
	local target = source
	local license = GetIdentifier(target, 'license')
	for k, v in pairs(Config.Roles) do
		RoleToPrincipal(target, k, license)
	end
end)

function RoleToPrincipal(user, role, license)
	if IsRolePresent(user, role) then
		local group = Config.Roles[role].group
		ExecuteCommand('remove_principal identifier.' .. license .. " group." .. group ) --remover o principal evita possíveis duplicatas
		ExecuteCommand('add_principal identifier.' .. license .. " group." .. group )
		print('Adicionado principal para ' .. group)
    end
end

function GetIdentifier(serverId, search)
	for i,identifier in ipairs(GetPlayerIdentifiers(serverId)) do
		if string.find(identifier, search) then
			return identifier
		end
	end
end

Citizen.CreateThread(function()
	local guild = DiscordRequest("GET", "guilds/"..Config.GuildId, {})
	if guild.code == 200 then
		local data = json.decode(guild.data)
		print("Guilda do sistema de permissão definida para: "..data.name.." ("..data.id..")")
	else
		print("Ocorreu um erro, verifique sua configuração e verifique se tudo está correto. Erro: "..(guild.data or guild.code)) 
	end
end)
