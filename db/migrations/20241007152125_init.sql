-- migrate:up

-- Таблица компаний
CREATE TABLE companies (
    "id" BIGSERIAL PRIMARY KEY,
    "name" VARCHAR NOT NULL,
    "created_at" timestamptz NOT NULL DEFAULT NOW()
);

-- Таблица студий
CREATE TABLE studios (
    "id" BIGSERIAL PRIMARY KEY,
    "city_id" BIGSERIAL,
    "admin_id" BIGSERIAL,
    "company_id" BIGSERIAL REFERENCES companies ON DELETE CASCADE,
    "name" VARCHAR NOT NULL,
    "address" VARCHAR NOT NULL,
    "created_at" timestamptz NOT NULL DEFAULT NOW(),
    UNIQUE ("company_id", "address")
);

-- Таблица должностей
CREATE TABLE positions (
    "id" BIGSERIAL PRIMARY KEY,
    "name" VARCHAR NOT NULL UNIQUE,
    "created_at" timestamptz NOT NULL DEFAULT NOW()
);

-- Таблица сотрудников
CREATE TABLE staff (
    "id" BIGSERIAL PRIMARY KEY,
    "studio_id" BIGSERIAL REFERENCES studios ON DELETE CASCADE,
    "user_id" BIGSERIAL,
    "position_id" BIGSERIAL REFERENCES positions ON DELETE CASCADE,
    "created_at" timestamptz NOT NULL DEFAULT NOW()
);

-- Таблица услуг
CREATE TABLE services (
    "id" BIGSERIAL PRIMARY KEY,
    "studio_id" BIGSERIAL REFERENCES studios ON DELETE CASCADE,
    "name" VARCHAR NOT NULL,
    "description" TEXT,
    "duration_minutes" INTEGER NOT NULL,
    "created_at" timestamptz NOT NULL DEFAULT NOW(),
    UNIQUE ("studio_id", "name")
);

COMMENT ON INDEX services_studio_id_name_key IS 'Уникальный индекс на комбинацию studio_id и name для гарантии уникальности услуг в пределах одной студии';

-- Таблица цен на услуги
CREATE TABLE service_prices (
    "id" BIGSERIAL PRIMARY KEY,
    "service_id" BIGSERIAL REFERENCES services ON DELETE CASCADE,
    "price" NUMERIC(10, 2) NOT NULL,
    "valid_from" timestamptz NOT NULL DEFAULT NOW(),
    "valid_to" timestamptz
);

-- Тип ENUM для статуса записей клиентов
CREATE TYPE appointment_status AS ENUM ('Scheduled', 'Completed', 'Cancelled');

-- Таблица записей клиентов
CREATE TABLE reserves (
    "id" BIGSERIAL PRIMARY KEY,
    "user_id" BIGSERIAL,
    "service_id" BIGSERIAL REFERENCES services ON DELETE CASCADE,
    "datetime" timestamptz NOT NULL,
    "status" appointment_status NOT NULL DEFAULT 'Scheduled',
    "created_at" timestamptz NOT NULL DEFAULT NOW(),
    UNIQUE ("user_id", "service_id", "datetime")
);

COMMENT ON INDEX reserves_user_id_service_id_start_time_key IS 'Уникальный индекс на комбинацию user_id, service_id и start_time для предотвращения дублирования записей на одну и ту же услугу в одно и то же время';

-- Функция для проверки даты
CREATE OR REPLACE FUNCTION check_price_date()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.valid_from < NOW() THEN
        RAISE EXCEPTION 'Cannot set valid_from to a past date';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Триггер для проверки даты перед вставкой или обновлением
CREATE TRIGGER trg_check_price_date
BEFORE INSERT OR UPDATE ON service_prices
FOR EACH ROW
EXECUTE FUNCTION check_price_date();

-- migrate:down

