--- Configuração ---
notWhitelisted = "Você não está na lista de permissões deste servidor. Entre em nosso discord: COMMUNITY_LINK" -- Mensagem exibida quando não estão na lista de permissões com a função
noDiscord = "Você deve deixar o Discord aberto para entrar neste servidor." -- Mensagem exibida quando a discord não é encontrada

roles = { -- Nomes de função necessários para passar a lista de permissões
    "Admin",
    "Whitelisted",
    "Cidadao",
}


--- Codigo ---

AddEventHandler("playerConnecting", function(name, setCallback, deferrals)
    local src = source
    deferrals.defer()
    deferrals.update("Checking Permissions")

    for k, v in ipairs(GetPlayerIdentifiers(src)) do
        if string.sub(v, 1, string.len("discord:")) == "discord:" then
            identifierDiscord = v
        end
    end

    if identifierDiscord then
        for i = 1, #roles do
            if exports.discord_perms:IsRolePresent(src, roles[i]) then
                deferrals.done()
            else
                deferrals.done(notWhitelisted)
            end
        end
    else
        deferrals.done(noDiscord)
    end
end)
