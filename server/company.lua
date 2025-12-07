-- ============================================
-- COMPANY.LUA - CRUD Empresa
-- ============================================

lib.callback.register('mx_enterprise:getCompanies', function(source)
    local result = MySQL.query.await('SELECT * FROM companies ORDER BY name ASC')
    return result or {}
end)

lib.callback.register('mx_enterprise:getCompany', function(source, companyId)
    local result = MySQL.single.await('SELECT * FROM companies WHERE id = ?', {companyId})
    return result
end)

lib.callback.register('mx_enterprise:createCompany', function(source, data)
    local identifier = Utils.GetIdentifier(source)
    if not identifier then
        return false, Locales.Get('identifier_not_found')
    end
    
    local isAdmin = Utils.IsAdmin(source)
    
    if data.cnpj then
        local exists = MySQL.single.await('SELECT id FROM companies WHERE cnpj = ?', {data.cnpj})
        if exists then
            return false, 'CNPJ já cadastrado'
        end
    end
    
    local result = MySQL.insert.await([[
        INSERT INTO companies (name, label, type, cnpj, blip_x, blip_y, blip_z, blip_enabled, blip_sprite, blip_color, meta)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ]], {
        data.name, 
        data.label, 
        data.type, 
        data.cnpj, 
        data.blip_x or nil,
        data.blip_y or nil,
        data.blip_z or nil,
        data.blip_enabled and 1 or 0,
        data.blip_sprite or nil,
        data.blip_color or nil,
        json.encode(data.meta or {})
    })
    
    if result then
        MySQL.insert.await('INSERT INTO company_bank (company_id, balance) VALUES (?, ?)', {result, 0})
        
        if not isAdmin or data.add_as_owner then
            MySQL.insert.await([[
                INSERT INTO company_user (company_id, identifier, is_owner, is_manager, status)
                VALUES (?, ?, 1, 1, 'active')
            ]], {result, identifier})
        end
        
        TriggerClientEvent('mx_enterprise:refreshBlips', -1)
        
        return true, result
    end
    
    return false, 'Erro ao criar empresa'
end)

lib.callback.register('mx_enterprise:updateCompany', function(source, companyId, data)
    local identifier = Utils.GetIdentifier(source)
    if not identifier then
        return false, Locales.Get('identifier_not_found')
    end
    
    local isAdmin = Utils.IsAdmin(source)
    local hasPermission = isAdmin
    
    if not isAdmin then
        local member = MySQL.single.await([[
            SELECT * FROM company_user 
            WHERE company_id = ? AND identifier = ? AND (is_owner = 1 OR is_manager = 1) AND status = 'active'
        ]], {companyId, identifier})
        
        if member then
            hasPermission = true
        end
    end
    
    if not hasPermission then
        return false, Locales.Get('no_permission')
    end
    
    local updateFields = {}
    local updateValues = {}
    
    if data.name then
        table.insert(updateFields, 'name = ?')
        table.insert(updateValues, data.name)
    end
    if data.label then
        table.insert(updateFields, 'label = ?')
        table.insert(updateValues, data.label)
    end
    if data.type then
        table.insert(updateFields, 'type = ?')
        table.insert(updateValues, data.type)
    end
    if data.blip_x ~= nil then
        table.insert(updateFields, 'blip_x = ?')
        table.insert(updateValues, data.blip_x)
    end
    if data.blip_y ~= nil then
        table.insert(updateFields, 'blip_y = ?')
        table.insert(updateValues, data.blip_y)
    end
    if data.blip_z ~= nil then
        table.insert(updateFields, 'blip_z = ?')
        table.insert(updateValues, data.blip_z)
    end
    if data.blip_enabled ~= nil then
        table.insert(updateFields, 'blip_enabled = ?')
        table.insert(updateValues, data.blip_enabled and 1 or 0)
    end
    if data.blip_sprite ~= nil then
        table.insert(updateFields, 'blip_sprite = ?')
        table.insert(updateValues, data.blip_sprite)
    end
    if data.blip_color ~= nil then
        table.insert(updateFields, 'blip_color = ?')
        table.insert(updateValues, data.blip_color)
    end
    if data.meta then
        table.insert(updateFields, 'meta = ?')
        table.insert(updateValues, json.encode(data.meta))
    end
    
    if #updateFields > 0 then
        table.insert(updateValues, companyId)
        local query = 'UPDATE companies SET ' .. table.concat(updateFields, ', ') .. ' WHERE id = ?'
        MySQL.update.await(query, updateValues)
        
        print('^2[mx_enterprise]^7 [SERVER] Empresa atualizada, disparando refreshBlips para todos os clientes')
        TriggerClientEvent('mx_enterprise:refreshBlips', -1)
        
        return true
    end
    
    return false, 'Nenhum campo para atualizar'
end)

lib.callback.register('mx_enterprise:deleteCompany', function(source, companyId)
    local identifier = Utils.GetIdentifier(source)
    if not identifier then
        return false, Locales.Get('identifier_not_found')
    end
    
    local isAdmin = Utils.IsAdmin(source)
    local canDelete = isAdmin
    
    if not isAdmin then
        local member = MySQL.single.await([[
            SELECT * FROM company_user 
            WHERE company_id = ? AND identifier = ? AND is_owner = 1 AND status = 'active'
        ]], {companyId, identifier})
        
        if member then
            canDelete = true
        end
    end
    
    if not canDelete then
        return false, 'Apenas o dono ou administrador pode deletar a empresa'
    end
    
    MySQL.update.await('DELETE FROM companies WHERE id = ?', {companyId})
    
    TriggerClientEvent('mx_enterprise:refreshBlips', -1)
    
    return true
end)

lib.callback.register('mx_enterprise:isAdmin', function(source)
    return Utils.IsAdmin(source)
end)
