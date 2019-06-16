--- Configuração ---
roleNeeded = "Membro" -- O nome da função necessário para passar a lista de permissões
notWhitelisted = "Você não está na lista de permissões deste servidor. Entre em nosso discord: COMMUNITY_LINK" -- Mensagem exibida quando não estão na lista de permissões com a função
noDiscord = "Você deve deixar o Discord aberto para entrar neste servidor." -- Mensagem exibida quando a discord não é encontrada

--- Codigo ---

AddEventHandler("playerConnecting", function(name, setCallback, deferrals)
    local src = source
    deferrals.defer()
    deferrals.update("Verificando Permissões")

    for k, v in ipairs(GetPlayerIdentifiers(src)) do
        if string.sub(v, 1, string.len("discord:")) == "discord:" then
            identifierDiscord = v
        end
    end

    local allowed = false
    if identifierDiscord then
        if exports.discord_perms:IsRolePresent(src, roleNeeded) then
            deferrals.done()
            allowed = true
        else
            deferrals.done(notWhitelisted)
        end
    else
        deferrals.done(noDiscord)
    end
end)
