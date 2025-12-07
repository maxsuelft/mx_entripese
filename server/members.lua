-- ============================================
-- MEMBERS.LUA - Membros e Cargos
-- ============================================

lib.callback.register('mx_enterprise:getMembers', function(source, companyId)
    local result = MySQL.query.await('SELECT * FROM company_user WHERE company_id = ? AND status = "active"', {companyId})
    return result or {}
end)

lib.callback.register('mx_enterprise:getPlayerCompanies', function(source)
    local identifier = Utils.GetIdentifier(source)
    if not identifier then
        return {}
    end
    
    local result = MySQL.query.await('SELECT DISTINCT c.* FROM companies c JOIN company_user cu ON c.id = cu.company_id WHERE cu.identifier = ? AND cu.status = "active"', {identifier})
    return result or {}
end)

lib.callback.register('mx_enterprise:addMember', function(source, companyId, targetId, roleId)
    local identifier = Utils.GetIdentifier(source)
    local targetIdentifier = Utils.GetIdentifier(targetId)
    
    if not identifier or not targetIdentifier then
        return false, 'Erro ao obter identificadores'
    end
    
    local member = MySQL.single.await('SELECT * FROM company_user WHERE company_id = ? AND identifier = ? AND (is_owner = 1 OR is_manager = 1) AND status = "active"', {companyId, identifier})
    
    if not member then
        return false, 'Você não tem permissão'
    end
    
    local exists = MySQL.single.await('SELECT id FROM company_user WHERE company_id = ? AND identifier = ?', {companyId, targetIdentifier})
    if exists then
        return false, 'Membro já está na empresa'
    end
    
    local result = MySQL.insert.await('INSERT INTO company_user (company_id, identifier, role_id, status) VALUES (?, ?, ?, "active")', {companyId, targetIdentifier, roleId})
    
    if result then
        TriggerClientEvent('mx_enterprise:memberAdded', -1, companyId, targetIdentifier)
        return true
    end
    
    return false, 'Erro ao adicionar membro'
end)

lib.callback.register('mx_enterprise:removeMember', function(source, companyId, memberId)
    local identifier = Utils.GetIdentifier(source)
    if not identifier then
        return false, 'Identificador não encontrado'
    end
    
    local member = MySQL.single.await('SELECT * FROM company_user WHERE company_id = ? AND identifier = ? AND (is_owner = 1 OR is_manager = 1) AND status = "active"', {companyId, identifier})
    
    if not member then
        return false, 'Você não tem permissão'
    end
    
    MySQL.update.await('UPDATE company_user SET status = "left" WHERE id = ?', {memberId})
    
    TriggerClientEvent('mx_enterprise:memberRemoved', -1, companyId, memberId)
    
    return true
end)

lib.callback.register('mx_enterprise:updateMember', function(source, companyId, memberId, data)
    local identifier = Utils.GetIdentifier(source)
    if not identifier then
        return false, 'Identificador não encontrado'
    end
    
    local member = MySQL.single.await('SELECT * FROM company_user WHERE company_id = ? AND identifier = ? AND (is_owner = 1 OR is_manager = 1) AND status = "active"', {companyId, identifier})
    
    if not member then
        return false, 'Você não tem permissão'
    end
    
    local updateFields = {}
    local updateValues = {}
    
    if data.role_id then
        table.insert(updateFields, 'role_id = ?')
        table.insert(updateValues, data.role_id)
    end
    if data.is_manager ~= nil then
        table.insert(updateFields, 'is_manager = ?')
        table.insert(updateValues, data.is_manager and 1 or 0)
    end
    
    if #updateFields > 0 then
        table.insert(updateValues, memberId)
        local query = 'UPDATE company_user SET ' .. table.concat(updateFields, ', ') .. ' WHERE id = ?'
        MySQL.update.await(query, updateValues)
        
        return true
    end
    
    return false, 'Nenhum campo para atualizar'
end)

lib.callback.register('mx_enterprise:getRoles', function(source, companyId)
    local result = MySQL.query.await('SELECT * FROM company_roles WHERE company_id = ? ORDER BY name ASC', {companyId})
    return result or {}
end)

lib.callback.register('mx_enterprise:createRole', function(source, companyId, roleData)
    local identifier = Utils.GetIdentifier(source)
    if not identifier then
        return false, 'Identificador não encontrado'
    end
    
    local member = MySQL.single.await('SELECT * FROM company_user WHERE company_id = ? AND identifier = ? AND (is_owner = 1 OR is_manager = 1) AND status = "active"', {companyId, identifier})
    
    if not member then
        return false, 'Você não tem permissão'
    end
    
    local result = MySQL.insert.await('INSERT INTO company_roles (company_id, name, salary, permissions) VALUES (?, ?, ?, ?)', {companyId, roleData.name, roleData.salary or 0, json.encode(roleData.permissions or {})})
    
    if result then
        return true, result
    end
    
    return false, 'Erro ao criar cargo'
end)

lib.callback.register('mx_enterprise:deleteRole', function(source, companyId, roleId)
    local identifier = Utils.GetIdentifier(source)
    if not identifier then
        return false, 'Identificador não encontrado'
    end
    
    local member = MySQL.single.await('SELECT * FROM company_user WHERE company_id = ? AND identifier = ? AND is_owner = 1 AND status = "active"', {companyId, identifier})
    
    if not member then
        return false, 'Você não tem permissão'
    end
    
    MySQL.update.await('DELETE FROM company_roles WHERE id = ? AND company_id = ?', {roleId, companyId})
    
    return true
end)
