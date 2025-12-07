-- ============================================
-- mx_enterprise - SERVER MAIN
-- Inicialização e criação de tabelas
-- ============================================

CreateThread(function()
    Wait(1000)
    print('^2[mx_enterprise]^7 Sistema de Empresas carregado!')
    
    -- Criar todas as tabelas
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS companies (
          id INT AUTO_INCREMENT PRIMARY KEY,
          name VARCHAR(100) NOT NULL,
          label VARCHAR(120) NOT NULL,
          type ENUM('industry','service','commerce','mixed') DEFAULT 'mixed',
          cnpj VARCHAR(32) UNIQUE,
          blip_x FLOAT NULL,
          blip_y FLOAT NULL,
          blip_z FLOAT NULL,
          blip_enabled TINYINT(1) DEFAULT 0,
          blip_sprite VARCHAR(100) NULL,
          blip_color VARCHAR(50) NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
          meta JSON DEFAULT NULL
        )
    ]])
    
    -- Adicionar colunas de blip se não existirem (migração)
    MySQL.query([[
        ALTER TABLE companies 
        ADD COLUMN IF NOT EXISTS blip_x FLOAT NULL,
        ADD COLUMN IF NOT EXISTS blip_y FLOAT NULL,
        ADD COLUMN IF NOT EXISTS blip_z FLOAT NULL,
        ADD COLUMN IF NOT EXISTS blip_enabled TINYINT(1) DEFAULT 0,
        ADD COLUMN IF NOT EXISTS blip_sprite VARCHAR(100) NULL,
        ADD COLUMN IF NOT EXISTS blip_color VARCHAR(50) NULL
    ]])
    
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS company_roles (
          id INT AUTO_INCREMENT PRIMARY KEY,
          company_id INT NOT NULL,
          name VARCHAR(100) NOT NULL,
          salary INT DEFAULT 0,
          permissions JSON DEFAULT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          UNIQUE KEY uk_role (company_id, name),
          FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
        )
    ]])
    
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS company_user (
          id INT AUTO_INCREMENT PRIMARY KEY,
          company_id INT NOT NULL,
          identifier VARCHAR(100) NOT NULL,
          role_id INT NULL,
          is_owner TINYINT(1) DEFAULT 0,
          is_manager TINYINT(1) DEFAULT 0,
          status ENUM('active','suspended','left') DEFAULT 'active',
          joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          last_seen_at TIMESTAMP NULL,
          meta JSON DEFAULT NULL,
          UNIQUE KEY uk_company_user (company_id, identifier),
          INDEX idx_identifier (identifier),
          INDEX idx_company (company_id),
          FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
          FOREIGN KEY (role_id) REFERENCES company_roles(id) ON DELETE SET NULL
        )
    ]])
    
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS company_storage (
          id INT AUTO_INCREMENT PRIMARY KEY,
          company_id INT NOT NULL,
          item VARCHAR(100) NOT NULL,
          amount INT DEFAULT 0,
          updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
          UNIQUE KEY uk_storage (company_id, item),
          FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
        )
    ]])
    
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS company_vault (
          id INT AUTO_INCREMENT PRIMARY KEY,
          company_id INT NOT NULL,
          item VARCHAR(100) NOT NULL,
          amount INT DEFAULT 0,
          updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
          UNIQUE KEY uk_vault (company_id, item),
          FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
        )
    ]])
    
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS company_bank (
          id INT AUTO_INCREMENT PRIMARY KEY,
          company_id INT NOT NULL,
          balance INT DEFAULT 0,
          updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
          UNIQUE KEY uk_bank (company_id),
          FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
        )
    ]])
    
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS company_bank_transactions (
          id INT AUTO_INCREMENT PRIMARY KEY,
          company_id INT NOT NULL,
          identifier VARCHAR(100) NULL,
          type ENUM('deposit','withdraw','payroll','purchase','sale','fee') NOT NULL,
          amount INT NOT NULL,
          note VARCHAR(255) NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
        )
    ]])
    
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS company_shop (
          id INT AUTO_INCREMENT PRIMARY KEY,
          company_id INT NOT NULL,
          item VARCHAR(100) NOT NULL,
          price INT NOT NULL,
          stock INT DEFAULT 0,
          updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
          UNIQUE KEY uk_company_shop (company_id, item),
          FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
        )
    ]])
    
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS company_craft (
          id INT AUTO_INCREMENT PRIMARY KEY,
          company_id INT NOT NULL,
          result_item VARCHAR(100) NOT NULL,
          result_amount INT NOT NULL DEFAULT 1,
          recipe JSON NOT NULL,
          craft_time INT DEFAULT 5,
          UNIQUE KEY uk_company_craft (company_id, result_item),
          FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
        )
    ]])
    
    print('^2[mx_enterprise]^7 Tabelas do banco de dados verificadas!')
end)

-- Server Callbacks para a NUI (usando lib.callback)
lib.callback.register('mx_enterprise:getCompanies', function(source)
    local result = MySQL.query.await('SELECT * FROM companies ORDER BY name ASC')
    return result or {}
end)

lib.callback.register('mx_enterprise:getMembers', function(source, companyId)
    local result = MySQL.query.await('SELECT * FROM company_user WHERE company_id = ? AND status = "active"', {companyId})
    return result or {}
end)

lib.callback.register('mx_enterprise:getBank', function(source, companyId)
    local balance = MySQL.single.await('SELECT balance FROM company_bank WHERE company_id = ?', {companyId})
    local transactions = MySQL.query.await('SELECT * FROM company_bank_transactions WHERE company_id = ? ORDER BY created_at DESC LIMIT 50', {companyId})
    return {
        balance = balance and balance.balance or 0,
        transactions = transactions or {}
    }
end)

lib.callback.register('mx_enterprise:getStorage', function(source, companyId)
    local result = MySQL.query.await('SELECT * FROM company_storage WHERE company_id = ?', {companyId})
    return result or {}
end)

lib.callback.register('mx_enterprise:getCrafts', function(source, companyId)
    local result = MySQL.query.await('SELECT * FROM company_craft WHERE company_id = ?', {companyId})
    return result or {}
end)

lib.callback.register('mx_enterprise:getShop', function(source, companyId)
    local result = MySQL.query.await('SELECT * FROM company_shop WHERE company_id = ?', {companyId})
    return result or {}
end)

-- Callback para listar sprites de blips disponíveis do jo_libs
lib.callback.register('mx_enterprise:getAvailableBlipSprites', function(source)
    -- Lista de sprites comuns do RedM (usando nomes do jo_libs)
    return {
        { sprite = 'BLIP_AMBIENT_HORSE', name = 'Cavalo' },
        { sprite = 'BLIP_AMBIENT_PED', name = 'NPC' },
        { sprite = 'BLIP_AMBIENT_VEHICLE', name = 'Veículo' },
        { sprite = 'BLIP_AMBIENT_TRAIN', name = 'Trem' },
        { sprite = 'BLIP_AMBIENT_BOAT', name = 'Barco' },
        { sprite = 'BLIP_AMBIENT_STAGE', name = 'Palco' },
        { sprite = 'BLIP_AMBIENT_CAMP', name = 'Acampamento' },
        { sprite = 'BLIP_AMBIENT_HIDEOUT', name = 'Esconderijo' },
        { sprite = 'BLIP_AMBIENT_SHOP', name = 'Loja' },
        { sprite = 'BLIP_AMBIENT_SALOON', name = 'Salão' },
        { sprite = 'BLIP_AMBIENT_DOCTOR', name = 'Médico' },
        { sprite = 'BLIP_AMBIENT_GUNSMITH', name = 'Armeiro' },
        { sprite = 'BLIP_AMBIENT_BANK', name = 'Banco' },
        { sprite = 'BLIP_AMBIENT_POST_OFFICE', name = 'Correios' },
        { sprite = 'BLIP_AMBIENT_TRAIN_STATION', name = 'Estação de Trem' },
        { sprite = 'BLIP_AMBIENT_OFFICE', name = 'Escritório' },
        { sprite = 'BLIP_AMBIENT_HOUSE', name = 'Casa' },
        { sprite = 'BLIP_AMBIENT_TOWN', name = 'Cidade' }
    }
end)

-- Callback para listar cores disponíveis
lib.callback.register('mx_enterprise:getAvailableBlipColors', function(source)
    -- Cores disponíveis no jo_libs
    return {
        'WHITE',
        'RED',
        'GREEN',
        'BLUE',
        'YELLOW',
        'ORANGE',
        'PURPLE',
        'PINK',
        'LIGHT_BLUE',
        'LIGHT_GREEN',
        'LIGHT_RED',
        'BLACK'
    }
end)
