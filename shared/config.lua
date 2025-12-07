-- Carregar config.json
local configFile = LoadResourceFile(GetCurrentResourceName(), 'config.json')
if configFile then
    Config = json.decode(configFile)
else
    -- Fallback se não conseguir carregar
    Config = {
        locale = 'pt-br',
        debug = false,
        permissions = {
            manage_members = 'manage_members',
            manage_roles = 'manage_roles',
            manage_storage = 'manage_storage',
            manage_vault = 'manage_vault',
            manage_bank = 'manage_bank',
            manage_shop = 'manage_shop',
            manage_craft = 'manage_craft',
            view_reports = 'view_reports'
        },
        companyTypes = {
            industry = 'Indústria',
            service = 'Serviço',
            commerce = 'Comércio',
            mixed = 'Misto'
        },
        payroll = {
            enabled = true,
            interval = 3600000,
            min_salary = 0,
            max_salary = 10000
        },
        storage = {
            max_items = 50,
            default_capacity = 1000
        },
        bank = {
            min_withdraw = 1,
            max_withdraw = 100000,
            transaction_fee = 0.05
        },
        craft = {
            default_time = 5,
            require_station = false
        },
        shop = {
            max_items = 100,
            allow_stock_management = true
        }
    }
end

