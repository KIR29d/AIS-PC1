-- ============================================
-- База данных для АИС магазина кастомных ПК
-- ============================================

CREATE DATABASE CustomPC_AIS;
GO

USE CustomPC_AIS;
GO

-- ============================================
-- Таблица ролей
-- ============================================
CREATE TABLE роли (
    роль_id INT IDENTITY(1,1) PRIMARY KEY,
    название_роли VARCHAR(50) NOT NULL UNIQUE
);
GO

-- ============================================
-- Таблица отделы
-- ============================================
CREATE TABLE отделы (
    отдел_id INT IDENTITY(1,1) PRIMARY KEY,
    название VARCHAR(100) NOT NULL
);
GO

-- ============================================
-- Таблица клиенты
-- ============================================
CREATE TABLE клиенты (
    клиент_id INT IDENTITY(1,1) PRIMARY KEY,
    тип_клиента VARCHAR(20) NOT NULL CHECK (тип_клиента IN ('физическое', 'юридическое')),
    фамилия VARCHAR(100) NULL,
    имя VARCHAR(100) NULL,
    отчество VARCHAR(100) NULL,
    наименование_организации VARCHAR(255) NULL,
    email VARCHAR(255) NOT NULL,
    номер_телефона VARCHAR(20) NOT NULL,
    дата_регистрации DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- ============================================
-- Таблица сотрудники
-- ============================================
CREATE TABLE сотрудники (
    сотрудник_id INT IDENTITY(1,1) PRIMARY KEY,
    фамилия VARCHAR(100) NOT NULL,
    имя VARCHAR(100) NOT NULL,
    отчество VARCHAR(100) NULL,
    должность VARCHAR(100) NOT NULL,
    дата_приёма DATE NOT NULL,
    отдел_id INT NOT NULL FOREIGN KEY REFERENCES отделы(отдел_id)
);
GO

-- ============================================
-- Таблица пользователей
-- ============================================
CREATE TABLE пользователи (
    пользователь_id INT IDENTITY(1,1) PRIMARY KEY,
    логин VARCHAR(100) NOT NULL UNIQUE,
    пароль VARCHAR(255) NOT NULL,
    роль_id INT NOT NULL FOREIGN KEY REFERENCES роли(роль_id),
    сотрудник_id INT NULL FOREIGN KEY REFERENCES сотрудники(сотрудник_id),
    клиент_id INT NULL FOREIGN KEY REFERENCES клиенты(клиент_id),
    активен BIT NOT NULL DEFAULT 1,
    дата_создания DATETIME NOT NULL DEFAULT GETDATE(),
    дата_последнего_входа DATETIME NULL
);
GO

-- ============================================
-- Таблица склады
-- ============================================
CREATE TABLE склады (
    склад_id INT IDENTITY(1,1) PRIMARY KEY,
    название VARCHAR(100) NOT NULL,
    адрес NVARCHAR(MAX) NOT NULL
);
GO

-- ============================================
-- Таблица компоненты
-- ============================================
CREATE TABLE компоненты (
    компонент_id INT IDENTITY(1,1) PRIMARY KEY,
    наименование VARCHAR(255) NOT NULL,
    тип VARCHAR(50) NOT NULL,
    производитель VARCHAR(100) NOT NULL
);
GO

-- ============================================
-- Таблица остатки_на_складе
-- ============================================
CREATE TABLE остатки_на_складе (
    компонент_id INT NOT NULL FOREIGN KEY REFERENCES компоненты(компонент_id),
    склад_id INT NOT NULL FOREIGN KEY REFERENCES склады(склад_id),
    количество INT NOT NULL CHECK (количество >= 0),
    дата_обновления DATETIME NOT NULL DEFAULT GETDATE(),
    PRIMARY KEY (компонент_id, склад_id)
);
GO

-- ============================================
-- Таблица заказы
-- ============================================
CREATE TABLE заказы (
    заказ_id INT IDENTITY(1,1) PRIMARY KEY,
    клиент_id INT NOT NULL FOREIGN KEY REFERENCES клиенты(клиент_id),
    статус VARCHAR(50) NOT NULL CHECK (статус IN ('новый', 'в_работе', 'собран', 'отгружен', 'выполнен')),
    общая_сумма DECIMAL(12,2) NOT NULL,
    дата_создания DATETIME NOT NULL DEFAULT GETDATE(),
    дата_отгрузки DATETIME NULL
);
GO

-- ============================================
-- Таблица сборочные_задания
-- ============================================
CREATE TABLE сборочные_задания (
    сборка_id INT IDENTITY(1,1) PRIMARY KEY,
    название_конфигурации VARCHAR(255) NOT NULL,
    статус VARCHAR(50) NOT NULL CHECK (статус IN ('ожидает', 'в_сборке', 'готово')),
    сотрудник_id INT NULL FOREIGN KEY REFERENCES сотрудники(сотрудник_id),
    заказ_id INT NULL FOREIGN KEY REFERENCES заказы(заказ_id),
    дата_начала DATETIME NULL,
    дата_завершения DATETIME NULL
);
GO

-- ============================================
-- Таблица компоненты_в_сборке
-- ============================================
CREATE TABLE компоненты_в_сборке (
    сборка_id INT NOT NULL FOREIGN KEY REFERENCES сборочные_задания(сборка_id),
    компонент_id INT NOT NULL FOREIGN KEY REFERENCES компоненты(компонент_id),
    количество INT NOT NULL,
    PRIMARY KEY (сборка_id, компонент_id)
);
GO

-- ============================================
-- Таблица аудит_изменений
-- ============================================
CREATE TABLE аудит_изменений (
    аудит_id INT IDENTITY(1,1) PRIMARY KEY,
    таблица VARCHAR(100) NOT NULL,
    операция VARCHAR(10) NOT NULL CHECK (операция IN ('INSERT', 'UPDATE', 'DELETE')),
    пользователь_id INT NOT NULL FOREIGN KEY REFERENCES пользователи(пользователь_id),
    дата_изменения DATETIME NOT NULL DEFAULT GETDATE(),
    детали NVARCHAR(MAX) NOT NULL
);
GO

-- ============================================
-- Индексы для оптимизации
-- ============================================
CREATE INDEX IX_заказы_клиент_id ON заказы(клиент_id);
CREATE INDEX IX_заказы_статус ON заказы(статус);
CREATE INDEX IX_сборочные_задания_заказ_id ON сборочные_задания(заказ_id);
CREATE INDEX IX_сборочные_задания_сотрудник_id ON сборочные_задания(сотрудник_id);
CREATE INDEX IX_остатки_компонент_id ON остатки_на_складе(компонент_id);
CREATE INDEX IX_остатки_склад_id ON остатки_на_складе(склад_id);
GO

-- ============================================
-- Начальные данные
-- ============================================

-- Роли
INSERT INTO роли (название_роли) VALUES 
('Администратор'),
('Менеджер'),
('Сборщик'),
('Клиент');

-- Отделы
INSERT INTO отделы (название) VALUES 
('Отдел продаж'),
('Сборочный цех'),
('Склад'),
('Бухгалтерия');

-- Склады
INSERT INTO склады (название, адрес) VALUES 
('Основной склад', 'г. Москва, ул. Примерная, д. 1'),
('Склад комплектующих', 'г. Москва, ул. Примерная, д. 2');

GO
