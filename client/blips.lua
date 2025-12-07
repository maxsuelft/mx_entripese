-- ============================================
-- BLIPS.LUA - Sistema de Blips usando jo_libs
-- ============================================

local shopBlips = {}
local shopZones = {}

-- Verificar se jo_libs está disponível ao carregar
CreateThread(function()
    Wait(1000)
    if jo and jo.blip then
        print('^2[mx_enterprise]^7 jo_libs carregado com sucesso!')
    else
        print('^1[mx_enterprise]^7 ERRO: jo_libs não está disponível!')
        print('^1[mx_enterprise]^7 Verifique se jo_libs está instalado e carregado antes de mx_enterprise')
    end
end)

-- Carregar blips das lojas
local function loadShopBlips()
    print('^3[mx_enterprise]^7 Carregando blips...')

    -- Verificar se jo_libs está carregado
    if not jo or not jo.blip then
        print('^1[mx_enterprise]^7 ERRO: jo_libs não está carregado!')
        return
    end

    -- Limpar blips existentes
    for companyId, blipId in pairs(shopBlips) do
        if blipId then
            pcall(function()
                if jo and jo.blip and jo.blip.remove then
                    jo.blip.remove(blipId)
                end
            end)
        end
    end
    shopBlips = {}
    shopZones = {}

    -- Buscar empresas com blips habilitados
    lib.callback('mx_enterprise:getCompanies', false, function(companies)
        if not companies then
            print('^1[mx_enterprise]^7 Nenhuma empresa encontrada')
            return
        end

        print('^2[mx_enterprise]^7 Empresas encontradas: ' .. #companies)

        for _, company in ipairs(companies) do
            -- Debug: verificar dados da empresa
            print(string.format(
                '^3[mx_enterprise]^7 Empresa: %s | blip_enabled: %s (%s) | blip_x: %s | blip_y: %s | blip_z: %s',
                company.label or company.name,
                tostring(company.blip_enabled),
                type(company.blip_enabled),
                tostring(company.blip_x),
                tostring(company.blip_y),
                tostring(company.blip_z)))

            -- Verificar se blip está habilitado (pode ser 1, true, ou "1")
            local blipEnabled = company.blip_enabled == 1 or company.blip_enabled == true or company.blip_enabled == "1"

            if blipEnabled and company.blip_x and company.blip_y and company.blip_z then
                print(string.format('^3[mx_enterprise]^7 Criando blip para empresa: %s em %.2f, %.2f, %.2f',
                    company.label or company.name, company.blip_x, company.blip_y, company.blip_z))

                -- Criar blip usando jo_libs
                local location = vec3(company.blip_x, company.blip_y, company.blip_z)
                local name = company.label or company.name
                local sprite = company.blip_sprite or 'BLIP_AMBIENT_HORSE' -- Default sprite
                local color = company.blip_color or 'LIGHT_BLUE'

                local success, blipId = pcall(function()
                    return jo.blip.create(location, name, sprite, nil, color)
                end)

                if success and blipId then
                    print(string.format('^2[mx_enterprise]^7 Blip criado com sucesso! ID: %s | Sprite: %s | Cor: %s',
                        tostring(blipId), tostring(sprite), tostring(color)))
                    shopBlips[company.id] = blipId
                    shopZones[company.id] = {
                        company = company,
                        coords = vector3(company.blip_x, company.blip_y, company.blip_z),
                        distance = 2.0
                    }
                else
                    print(string.format(
                        '^1[mx_enterprise]^7 ERRO ao criar blip para empresa: %s | Sprite: %s | Erro: %s',
                        company.label or company.name, tostring(sprite), tostring(blipId)))
                end
            else
                print(string.format('^3[mx_enterprise]^7 Empresa %s não tem blip habilitado ou coordenadas',
                    company.label or company.name))
            end
        end

        local blipCount = 0
        for _ in pairs(shopBlips) do
            blipCount = blipCount + 1
        end
        print(string.format('^2[mx_enterprise]^7 Total de blips criados: %d', blipCount))
    end)
end

-- Evento para atualizar blips
RegisterNetEvent('mx_enterprise:refreshBlips', function()
    print('^3[mx_enterprise]^7 [BLIPS] Evento refreshBlips recebido, recarregando blips...')
    loadShopBlips()
end)

-- Carregar blips ao iniciar
CreateThread(function()
    Wait(2000)
    loadShopBlips()
end)

-- Exportar função para obter zonas
exports('getShopZones', function()
    return shopZones
end)
