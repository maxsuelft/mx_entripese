-- ============================================
-- NOTIFICATIONS.LUA - Sistema de Notificações usando ox_lib
-- ============================================

RegisterNetEvent('mx_enterprise:showNotification', function(title, message, notificationType)
    local type = notificationType or 'info'
    
    -- Usar ox_lib para mostrar notificações
    if lib and lib.notify then
        lib.notify({
            title = title or 'MX Enterprise',
            description = message,
            type = type,
            duration = 5000
        })
    else
        -- Fallback: usar print se ox_lib não estiver disponível
        local color = '^7'
        if type == 'success' then
            color = '^2'
        elseif type == 'error' then
            color = '^1'
        elseif type == 'warning' then
            color = '^3'
        end
        print(string.format('%s[mx_enterprise]^7 %s: %s', color, title or 'Notificação', message))
    end
end)