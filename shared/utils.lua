Utils = {}

-- Obter identifier do jogador
function Utils.GetIdentifier(source)
    local identifiers = GetPlayerIdentifiers(source)
    for _, identifier in ipairs(identifiers) do
        if string.find(identifier, 'steam:') or string.find(identifier, 'license:') then
            return identifier
        end
    end
    return nil
end

-- Verificar se tem permissão
function Utils.HasPermission(permissions, permission)
    if not permissions then return false end
    if type(permissions) == 'string' then
        permissions = json.decode(permissions)
    end
    return permissions[permission] == true
end

-- Formatar dinheiro
function Utils.FormatMoney(amount)
    return string.format("%.2f", amount)
end

-- Log
function Utils.Log(message)
    if Config.Debug then
        print('[mx_enterprise] ' .. message)
    end
end

-- Carregar config.json
function Utils.LoadConfig()
    local file = LoadResourceFile(GetCurrentResourceName(), 'config.json')
    if file then
        Config = json.decode(file)
        return true
    end
    return false
end

-- Obter identifier específico do jogador
function Utils.GetPlayerIdentifier(source, idType)
    local identifiers = GetPlayerIdentifiers(source)
    for _, identifier in ipairs(identifiers) do
        if string.find(identifier, idType .. ':') then
            return identifier
        end
    end
    return nil
end

-- Verificar se jogador é admin
function Utils.IsAdmin(source)
    if not Config.admin or not Config.admin.enabled then
        return false
    end
    
    local identifiers = GetPlayerIdentifiers(source)
    if not identifiers then return false end
    
    -- Verificar por Steam
    if Config.admin.steam and #Config.admin.steam > 0 then
        local steamId = Utils.GetPlayerIdentifier(source, 'steam')
        if steamId then
            for _, adminId in ipairs(Config.admin.steam) do
                if adminId == steamId then
                    return true
                end
            end
        end
    end
    
    -- Verificar por Discord
    if Config.admin.discord and #Config.admin.discord > 0 then
        local discordId = Utils.GetPlayerIdentifier(source, 'discord')
        if discordId then
            for _, adminId in ipairs(Config.admin.discord) do
                if adminId == discordId then
                    return true
                end
            end
        end
    end
    
    -- Verificar por FiveM/CFX
    if Config.admin.fivem and #Config.admin.fivem > 0 then
        local fivemId = Utils.GetPlayerIdentifier(source, 'fivem')
        if fivemId then
            for _, adminId in ipairs(Config.admin.fivem) do
                if adminId == fivemId then
                    return true
                end
            end
        end
    end
    
    -- Verificar por grupo do VORP (se habilitado)
    if Config.admin.use_vorp_groups and Config.admin.groups then
        local success, result = pcall(function()
            local User = exports.vorp_core:getUser(source)
            if User then
                local Character = User.getUsedCharacter
                if Character then
                    local group = Character.group
                    if group then
                        for _, adminGroup in ipairs(Config.admin.groups) do
                            if group == adminGroup then
                                return true
                            end
                        end
                    end
                end
            end
            return false
        end)
        
        if success and result then
            return true
        end
    end
    
    return false
end