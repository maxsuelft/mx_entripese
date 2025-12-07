-- ============================================
-- UI_OPEN.LUA - Teclas e Abertura do Painel
-- ============================================

local isUIOpen = false

-- Comando para abrir interface
RegisterCommand('empresa', function()
    if isUIOpen then
        closeUI()
        return
    end
    
    lib.callback('mx_enterprise:getPlayerCompanies', false, function(companies)
        if companies and #companies > 0 then
            openUI(companies)
        else
            TriggerEvent('mx_enterprise:showNotification', Locales.Get('no_companies'), 'error')
        end
    end)
end)

-- Comando para abrir interface administrativa
RegisterCommand('adminempresa', function()
    if isUIOpen then
        closeUI()
        return
    end
    
    lib.callback('mx_enterprise:isAdmin', false, function(isAdmin)
        if not isAdmin then
            TriggerEvent('mx_enterprise:showNotification', 'Você não tem permissão para usar este comando', 'error')
            return
        end
        
        -- Carregar todas as empresas para admin
        lib.callback('mx_enterprise:getCompanies', false, function(companies)
            openUIAdmin(companies or {})
        end)
    end)
end)

-- Comando alternativo
RegisterCommand('empresaadmin', function()
    ExecuteCommand('adminempresa')
end)

-- Abrir UI
function openUI(companies)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        companies = companies
    })
    isUIOpen = true
end

-- Abrir UI Admin (mostra todas as empresas)
function openUIAdmin(companies)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        companies = companies,
        adminMode = true
    })
    isUIOpen = true
end

-- Fechar UI
function closeUI()
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    isUIOpen = false
end

-- Exportar funções
exports('openUI', openUI)
exports('closeUI', closeUI)
