-- EMPRESAS
CREATE TABLE IF NOT EXISTS companies (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  label VARCHAR(120) NOT NULL,
  type ENUM('industry','service','commerce','mixed') DEFAULT 'mixed',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
  meta JSON DEFAULT NULL,
  blip_x FLOAT NULL,
  blip_y FLOAT NULL,
  blip_z FLOAT NULL,
  blip_enabled TINYINT(1) DEFAULT 0,
  blip_sprite VARCHAR(100) NULL,
  blip_color VARCHAR(50) NULL
);

-- CARGOS / ROLES
CREATE TABLE IF NOT EXISTS company_roles (
  id INT AUTO_INCREMENT PRIMARY KEY,
  company_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  salary INT DEFAULT 0,
  permissions JSON DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_role (company_id, name),
  FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
);

-- MEMBROS DA EMPRESA
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
);

-- ARMAZÉM DA EMPRESA
CREATE TABLE IF NOT EXISTS company_storage (
  id INT AUTO_INCREMENT PRIMARY KEY,
  company_id INT NOT NULL,
  item VARCHAR(100) NOT NULL,
  amount INT DEFAULT 0,
  updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_storage (company_id, item),
  FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
);

-- BAÚ / GERÊNCIA EXTRA
CREATE TABLE IF NOT EXISTS company_vault (
  id INT AUTO_INCREMENT PRIMARY KEY,
  company_id INT NOT NULL,
  item VARCHAR(100) NOT NULL,
  amount INT DEFAULT 0,
  updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_vault (company_id, item),
  FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
);

-- BANCO DA EMPRESA
CREATE TABLE IF NOT EXISTS company_bank (
  id INT AUTO_INCREMENT PRIMARY KEY,
  company_id INT NOT NULL,
  balance INT DEFAULT 0,
  updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_bank (company_id),
  FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
);

-- HISTÓRICO DE TRANSAÇÕES BANCÁRIAS
CREATE TABLE IF NOT EXISTS company_bank_transactions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  company_id INT NOT NULL,
  identifier VARCHAR(100) NULL,
  type ENUM('deposit','withdraw','payroll','purchase','sale','fee') NOT NULL,
  amount INT NOT NULL,
  note VARCHAR(255) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
);

-- SHOP DA EMPRESA
CREATE TABLE IF NOT EXISTS company_shop (
  id INT AUTO_INCREMENT PRIMARY KEY,
  company_id INT NOT NULL,
  item VARCHAR(100) NOT NULL,
  price INT NOT NULL,
  stock INT DEFAULT 0,
  updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_company_shop (company_id, item),
  FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
);

-- CRAFT DA EMPRESA
CREATE TABLE IF NOT EXISTS company_craft (
  id INT AUTO_INCREMENT PRIMARY KEY,
  company_id INT NOT NULL,
  result_item VARCHAR(100) NOT NULL,
  result_amount INT NOT NULL DEFAULT 1,
  recipe JSON NOT NULL,
  craft_time INT DEFAULT 5,
  UNIQUE KEY uk_company_craft (company_id, result_item),
  FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
);

