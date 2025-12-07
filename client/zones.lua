-- ============================================
-- ZONES.LUA - Sistema de Zonas e Interação usando Uiprompt
-- ============================================

local shopPrompts = {}
local shopZones = {}
local showingPrompts = {}

-- Função para criar prompt de uma loja
local function createShopPrompt(company)
    if not company or not company.blip_x or not company.blip_y or not company.blip_z then
        print('^1[mx_enterprise]^7 [PROMPT] Erro: empresa sem coordenadas')
        return nil
    end

    local location = vector3(company.blip_x, company.blip_y, company.blip_z)
    local promptText = "Abrir Loja" -- Sem nome da loja

    print(string.format('^3[mx_enterprise]^7 [PROMPT] Criando prompt em: %.2f, %.2f, %.2f',
        company.blip_x, company.blip_y, company.blip_z))

    -- Criar prompt usando Uiprompt
    -- Tecla G no RedM: 0x760A9C6F
    local gKeyHash = 0x760A9C6F
    local prompt = Uiprompt:new(gKeyHash, promptText)
    prompt:setHoldMode(false)
    prompt:setEnabled(false)
    -- Esconder visualmente também ao criar
    if prompt.setVisible then
        prompt:setVisible(false)
    end

    prompt:setOnJustPressed(function()
        print('^2[mx_enterprise]^7 [PROMPT] Tecla G pressionada')
        -- Progress bar para abrir loja
        lib.progressBar({
            duration = 2000,
            label = 'Abrindo loja...',
            canCancel = true,
            disable = { move = true, car = true },
            onFinish = function()
                print(string.format('^2[mx_enterprise]^7 Abrindo loja: %s',
                    company.label or company.name))
                openShop(company.id, company)
            end
        })
    end)

    print(string.format('^2[mx_enterprise]^7 [PROMPT] Prompt criado para loja: %s', company.label or company.name))

    return {
        prompt = prompt,
        company = company,
        location = location,
        enabled = false
    }
end

-- Função para remover prompt de uma loja completamente
local function removeShopPrompt(companyId)
    if shopPrompts[companyId] then
        if shopPrompts[companyId].prompt then
            -- Desabilitar e esconder antes de deletar
            shopPrompts[companyId].prompt:setEnabled(false)
            if shopPrompts[companyId].prompt.setVisible then
                shopPrompts[companyId].prompt:setVisible(false)
            end
            -- Tentar usar delete() se disponível
            if shopPrompts[companyId].prompt.delete then
                shopPrompts[companyId].prompt:delete()
            end
        end
        shopPrompts[companyId] = nil
        showingPrompts[companyId] = nil
    end
end

-- Função para recarregar todos os prompts
local function reloadShopPrompts()
    print('^3[mx_enterprise]^7 [PROMPT] Recarregando prompts...')

    -- Remover prompts existentes
    for companyId, _ in pairs(shopPrompts) do
        removeShopPrompt(companyId)
    end
    shopPrompts = {}
    shopZones = {}
    showingPrompts = {}

    -- Buscar empresas com blips habilitados
    lib.callback('mx_enterprise:getCompanies', false, function(companies)
        if not companies then
            print('^1[mx_enterprise]^7 [PROMPT] Nenhuma empresa encontrada')
            return
        end

        print('^2[mx_enterprise]^7 [PROMPT] Empresas encontradas: ' .. #companies)

        for _, company in ipairs(companies) do
            -- Verificar se blip está habilitado (pode ser 1, true, ou "1")
            local blipEnabled = company.blip_enabled == 1 or company.blip_enabled == true or company.blip_enabled == "1"

            if blipEnabled and company.blip_x and company.blip_y and company.blip_z then
                local promptData = createShopPrompt(company)
                if promptData then
                    shopPrompts[company.id] = promptData
                    shopZones[company.id] = {
                        company = company,
                        coords = vector3(company.blip_x, company.blip_y, company.blip_z),
                        distance = 2.0
                    }
                    showingPrompts[company.id] = false
                    print(string.format('^2[mx_enterprise]^7 [PROMPT] Prompt criado para loja: %s',
                        company.label or company.name))
                else
                    print(string.format('^1[mx_enterprise]^7 [PROMPT] ERRO ao criar prompt para loja: %s',
                        company.label or company.name))
                end
            else
                print(string.format('^3[mx_enterprise]^7 [PROMPT] Empresa %s não tem blip habilitado ou coordenadas',
                    company.label or company.name))
            end
        end

        local promptCount = 0
        for _ in pairs(shopPrompts) do
            promptCount = promptCount + 1
        end
        print(string.format('^2[mx_enterprise]^7 [PROMPT] Total de prompts criados: %d', promptCount))
    end)
end

-- Thread para verificar proximidade e mostrar/esconder prompts
CreateThread(function()
    while true do
        Wait(150)

        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        -- Verificar cada zona de loja
        for companyId, zone in pairs(shopZones) do
            if zone and zone.coords and shopPrompts[companyId] and shopPrompts[companyId].prompt then
                local distance = #(coords - zone.coords)
                local isShowing = showingPrompts[companyId] or false

                if distance <= zone.distance and not isShowing then
                    -- Perto → habilita e mostra
                    shopPrompts[companyId].prompt:setEnabled(true)
                    if shopPrompts[companyId].prompt.setVisible then
                        shopPrompts[companyId].prompt:setVisible(true)
                    end
                    -- Bloquear tudo se setActive estiver disponível (ativar)
                    if shopPrompts[companyId].prompt.setActive then
                        shopPrompts[companyId].prompt:setActive(true)
                    end
                    showingPrompts[companyId] = true
                    print(string.format('^2[mx_enterprise]^7 [PROMPT] Mostrando prompt (distância: %.2f)', distance))
                elseif distance > zone.distance and isShowing then
                    -- Longe → desabilita e esconde (some sem ficar cinza)
                    shopPrompts[companyId].prompt:setEnabled(false)
                    if shopPrompts[companyId].prompt.setVisible then
                        shopPrompts[companyId].prompt:setVisible(false)
                    end
                    -- Bloquear tudo se setActive estiver disponível
                    if shopPrompts[companyId].prompt.setActive then
                        shopPrompts[companyId].prompt:setActive(false)
                    end
                    showingPrompts[companyId] = false
                    print('^3[mx_enterprise]^7 [PROMPT] Escondendo prompt (saiu da zona)')
                end
            end
        end
    end
end)

-- Inicializar UipromptManager
CreateThread(function()
    Wait(2000) -- Esperar um pouco mais para garantir que uiprompt está carregado
    if UipromptManager then
        UipromptManager:startEventThread()
        print('^2[mx_enterprise]^7 [PROMPT] UipromptManager iniciado!')
    else
        print('^1[mx_enterprise]^7 [PROMPT] ERRO: UipromptManager não está disponível!')
        print('^1[mx_enterprise]^7 [PROMPT] Verifique se o script uiprompt está instalado e carregado')
    end
end)

-- Evento para atualizar prompts quando blips são atualizados
RegisterNetEvent('mx_enterprise:refreshBlips', function()
    print('^3[mx_enterprise]^7 [PROMPT] Evento refreshBlips recebido, recarregando prompts...')
    reloadShopPrompts()
end)

-- Carregar prompts ao iniciar
CreateThread(function()
    Wait(3000) -- Esperar um pouco mais para garantir que tudo está carregado
    reloadShopPrompts()
end)

-- Função para abrir loja
function openShop(companyId, company)
    -- Buscar itens da loja
    lib.callback('mx_enterprise:getShopItems', false, function(items)
        if items then
            -- Abrir NUI da loja
            SetNuiFocus(true, true)
            SendNUIMessage({
                action = 'openShop',
                companyId = companyId,
                company = company,
                items = items or {}
            })
        end
    end, companyId)
end

-- Callback NUI para fechar loja
RegisterNUICallback('closeShop', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Callback NUI para comprar item
RegisterNUICallback('buyShopItem', function(data, cb)
    lib.callback('mx_enterprise:buyItem', false, function(success, message)
        if success then
            TriggerEvent('mx_enterprise:showNotification', 'MX Enterprise', 'Item comprado com sucesso!', 'success')
            -- Atualizar loja
            openShop(data.companyId, data.company)
        else
            TriggerEvent('mx_enterprise:showNotification', 'MX Enterprise', message or 'Erro ao comprar item', 'error')
        end
        cb({ success = success, message = message })
    end, data.companyId, data.itemId, data.amount, data.totalPrice)
end)

-- Exportar função
exports('openShop', openShop)
