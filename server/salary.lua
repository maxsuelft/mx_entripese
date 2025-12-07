-- ============================================
-- SALARY.LUA - Salários e Pagamento Automático
-- ============================================

-- Sistema automático de pagamento de salários
CreateThread(function()
    if not Config.payroll.enabled then return end
    
    while true do
        Wait(Config.payroll.interval)
        
        local companies = MySQL.query.await('SELECT id FROM companies')
        if companies then
            for _, company in ipairs(companies) do
                local members = MySQL.query.await([[
                    SELECT cu.identifier, cr.salary, cr.id as role_id
                    FROM company_user cu
                    LEFT JOIN company_roles cr ON cu.role_id = cr.id
                    WHERE cu.company_id = ? AND cu.status = 'active' AND cr.salary > 0
                ]], {company.id})
                
                if members then
                    local totalPayroll = 0
                    for _, member in ipairs(members) do
                        totalPayroll = totalPayroll + (member.salary or 0)
                    end
                    
                    local bank = MySQL.single.await([[
                        SELECT balance FROM company_bank 
                        WHERE company_id = ?
                    ]], {company.id})
                    
                    if bank and bank.balance >= totalPayroll then
                        for _, member in ipairs(members) do
                            local salary = member.salary or 0
                            if salary > 0 then
                                local players = GetPlayers()
                                for _, playerId in ipairs(players) do
                                    local playerIdentifier = Utils.GetIdentifier(tonumber(playerId))
                                    if playerIdentifier == member.identifier then
                                        -- TODO: Adaptar para seu sistema de dinheiro
                                        -- TriggerEvent('vorp:addMoney', tonumber(playerId), salary)
                                        TriggerClientEvent('mx_enterprise:notification', tonumber(playerId), 
                                            'Você recebeu seu salário: $' .. salary, 'success')
                                        break
                                    end
                                end
                                
                                MySQL.insert.await([[
                                    INSERT INTO company_bank_transactions (company_id, identifier, type, amount, note)
                                    VALUES (?, ?, 'payroll', ?, ?)
                                ]], {company.id, member.identifier, salary, 'Pagamento de salário'})
                            end
                        end
                        
                        MySQL.update.await([[
                            UPDATE company_bank 
                            SET balance = balance - ? 
                            WHERE company_id = ?
                        ]], {totalPayroll, company.id})
                    end
                end
            end
        end
    end
end)

