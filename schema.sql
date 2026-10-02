-- ============================================================
-- College Bus Tracking & Pass Management System
-- DATABASE SCHEMA — MySQL
-- ============================================================
-- Run this file before starting the Spring Boot backend.
-- Command: mysql -u root -p < schema.sql
-- ============================================================

-- Create the database
CREATE DATABASE IF NOT EXISTS bus_tracking_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE bus_tracking_db;

-- ============================================================
-- TABLE: users
-- Stores all system users: students and admins
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
    id             BIGINT AUTO_INCREMENT PRIMARY KEY,
    name           VARCHAR(100)  NOT NULL,
    email          VARCHAR(150)  NOT NULL UNIQUE,
    password       VARCHAR(255)  NOT NULL,        -- BCrypt hash
    phone_number   VARCHAR(15),
    role           ENUM('STUDENT', 'ADMIN') NOT NULL DEFAULT 'STUDENT',
    roll_number    VARCHAR(20),                   -- Only for students
    department     VARCHAR(100),                  -- Only for students
    is_active      BOOLEAN       NOT NULL DEFAULT TRUE,
    created_at     DATETIME      DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_email (email),
    INDEX idx_role  (role)
);

-- ============================================================
-- TABLE: buses
-- Represents each physical bus in the college fleet
-- ============================================================
CREATE TABLE IF NOT EXISTS buses (
    id                     BIGINT AUTO_INCREMENT PRIMARY KEY,
    bus_number             VARCHAR(20)   NOT NULL UNIQUE,  -- e.g. KA-01-AB-1234
    driver_name            VARCHAR(100)  NOT NULL,
    driver_phone           VARCHAR(15),
    capacity               INT,                            -- Total seats
    status                 ENUM('ACTIVE', 'INACTIVE', 'MAINTENANCE') NOT NULL DEFAULT 'ACTIVE',
    current_latitude       DECIMAL(10, 7),                -- GPS latitude
    current_longitude      DECIMAL(10, 7),                -- GPS longitude
    current_location_name  VARCHAR(200),                  -- Human-readable location
    last_location_update   DATETIME,
    created_at             DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at             DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_bus_number (bus_number),
    INDEX idx_status     (status)
);

-- ============================================================
-- TABLE: routes
-- Defines each bus route (from A to B with stops)
-- ============================================================
CREATE TABLE IF NOT EXISTS routes (
    id                  BIGINT AUTO_INCREMENT PRIMARY KEY,
    route_name          VARCHAR(200)   NOT NULL,
    route_number        VARCHAR(20)    NOT NULL UNIQUE,   -- e.g. R-01
    start_point         VARCHAR(150),
    end_point           VARCHAR(150),
    departure_time      TIME,                              -- Morning departure
    return_time         TIME,                              -- Evening return
    total_distance_km   DECIMAL(6, 2),
    stops               TEXT,                              -- JSON or CSV of stops
    monthly_fee         DECIMAL(10, 2),                   -- Pass cost per month
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    bus_id              BIGINT,                            -- FK → buses.id
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (bus_id) REFERENCES buses(id) ON DELETE SET NULL,
    INDEX idx_route_number (route_number),
    INDEX idx_bus_id       (bus_id)
);

-- ============================================================
-- TABLE: bus_passes
-- A student's pass for a specific route
-- ============================================================
CREATE TABLE IF NOT EXISTS bus_passes (
    id                  BIGINT AUTO_INCREMENT PRIMARY KEY,
    pass_number         VARCHAR(30)    NOT NULL UNIQUE,   -- e.g. PASS-2024-00001
    student_id          BIGINT         NOT NULL,           -- FK → users.id
    route_id            BIGINT         NOT NULL,           -- FK → routes.id
    valid_from          DATE           NOT NULL,
    valid_to            DATE           NOT NULL,
    status              ENUM('PENDING', 'ACTIVE', 'EXPIRED', 'REJECTED', 'CANCELLED')
                        NOT NULL DEFAULT 'PENDING',
    amount_paid         DECIMAL(10, 2),
    payment_reference   VARCHAR(100),                     -- UPI/receipt ref
    boarding_stop       VARCHAR(150),                     -- Student's pickup stop
    remarks             TEXT,                              -- Admin notes
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (student_id) REFERENCES users(id)  ON DELETE CASCADE,
    FOREIGN KEY (route_id)   REFERENCES routes(id) ON DELETE CASCADE,
    INDEX idx_student_id (student_id),
    INDEX idx_status     (status),
    INDEX idx_pass_number (pass_number)
);

-- ============================================================
-- SEED DATA: Insert sample data for testing
-- ============================================================

-- ---- USERS ----
-- Password for all users: "admin123" and "student123"
-- These are BCrypt hashes — NEVER store plain text!
-- admin123  → $2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi
-- student123 → $2a$10$trT3.R/IPsseGPU9mTRnSuiHAMTd/AhnDsOeJnzvSHBhZADCQ0jKW

INSERT INTO users (name, email, password, phone_number, role, roll_number, department, is_active) VALUES
('Admin User',        'admin@nvpt.edu',    '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '9876543210', 'ADMIN',   NULL,      NULL,                 TRUE),
('Rajesh Kumar',      'rajesh@nvpt.edu',   '$2a$10$trT3.R/IPsseGPU9mTRnSuiHAMTd/AhnDsOeJnzvSHBhZADCQ0jKW', '9876543211', 'STUDENT', 'CS21001', 'Computer Science',   TRUE),
('Priya Sharma',      'priya@nvpt.edu',    '$2a$10$trT3.R/IPsseGPU9mTRnSuiHAMTd/AhnDsOeJnzvSHBhZADCQ0jKW', '9876543212', 'STUDENT', 'CS21002', 'Computer Science',   TRUE),
('Arun Patel',        'arun@nvpt.edu',     '$2a$10$trT3.R/IPsseGPU9mTRnSuiHAMTd/AhnDsOeJnzvSHBhZADCQ0jKW', '9876543213', 'STUDENT', 'ME21001', 'Mechanical Engg',    TRUE),
('Kavya Reddy',       'kavya@nvpt.edu',    '$2a$10$trT3.R/IPsseGPU9mTRnSuiHAMTd/AhnDsOeJnzvSHBhZADCQ0jKW', '9876543214', 'STUDENT', 'EC21001', 'Electronics',        TRUE),
('Student Demo',      'student@nvpt.edu',  '$2a$10$trT3.R/IPsseGPU9mTRnSuiHAMTd/AhnDsOeJnzvSHBhZADCQ0jKW', '9876543215', 'STUDENT', 'CS21003', 'Computer Science',   TRUE);

-- ---- BUSES ----
INSERT INTO buses (bus_number, driver_name, driver_phone, capacity, status, current_latitude, current_longitude, current_location_name) VALUES
('KA-01-AB-1234', 'Suresh Babu',     '9900001111', 45, 'ACTIVE',      12.9716, 77.5946, 'City Bus Stand'),
('KA-01-CD-5678', 'Mahesh Gowda',    '9900002222', 40, 'ACTIVE',      12.9352, 77.6245, 'Near Railway Station'),
('KA-01-EF-9012', 'Ramesh Kumar',    '9900003333', 50, 'ACTIVE',      NULL,    NULL,    NULL),
('KA-01-GH-3456', 'Venkat Rao',      '9900004444', 35, 'MAINTENANCE', NULL,    NULL,    NULL);

-- ---- ROUTES ----
INSERT INTO routes (route_name, route_number, start_point, end_point, departure_time, return_time, total_distance_km, stops, monthly_fee, is_active, bus_id) VALUES
('Route 1 - City Center to NVPT',  'R-01', 'City Bus Stand',         'NVPT College Gate', '07:30:00', '17:00:00', 15.5, 'Majestic, KR Market, Jayanagar, JP Nagar, NVPT', 800.00,  TRUE, 1),
('Route 2 - Railway Station to NVPT', 'R-02', 'KSR Railway Station', 'NVPT College Gate', '07:45:00', '17:15:00', 18.2, 'Railway Station, Yeshwanthpur, Rajajinagar, NVPT', 900.00,  TRUE, 2),
('Route 3 - Electronic City',      'R-03', 'Electronic City',        'NVPT College Gate', '07:15:00', '17:30:00', 22.0, 'Electronic City, Hosur Road, Silk Board, BTM, NVPT', 1000.00, TRUE, 3),
('Route 4 - Whitefield',           'R-04', 'Whitefield Bus Stop',    'NVPT College Gate', '07:00:00', '17:45:00', 28.5, 'Whitefield, Marathahalli, Outer Ring Road, NVPT', 1100.00, TRUE, NULL);

-- ---- BUS PASSES ----
INSERT INTO bus_passes (pass_number, student_id, route_id, valid_from, valid_to, status, amount_paid, payment_reference, boarding_stop) VALUES
('PASS-2024-00001', 2, 1, '2024-01-01', '2024-01-31', 'ACTIVE',    800.00,  'UPI-001234', 'Jayanagar'),
('PASS-2024-00002', 3, 2, '2024-01-01', '2024-01-31', 'ACTIVE',    900.00,  'UPI-001235', 'Yeshwanthpur'),
('PASS-2024-00003', 4, 3, '2024-01-01', '2024-01-31', 'PENDING',   1000.00, 'UPI-001236', 'Electronic City'),
('PASS-2024-00004', 5, 1, '2023-12-01', '2023-12-31', 'EXPIRED',   800.00,  'UPI-001237', 'KR Market'),
('PASS-2024-00005', 6, 2, '2024-01-01', '2024-01-31', 'PENDING',   900.00,  'UPI-001238', 'Railway Station');

-- ============================================================
-- VERIFICATION QUERIES (run these to check data)
-- ============================================================
-- SELECT * FROM users;
-- SELECT * FROM buses;
-- SELECT * FROM routes r JOIN buses b ON r.bus_id = b.id;
-- SELECT bp.pass_number, u.name, r.route_name, bp.status
--   FROM bus_passes bp
--   JOIN users u ON bp.student_id = u.id
--   JOIN routes r ON bp.route_id = r.id;
-- ============================================================

SELECT 'Database setup complete!' AS message;
SELECT COUNT(*) AS user_count FROM users;
SELECT COUNT(*) AS bus_count FROM buses;
SELECT COUNT(*) AS route_count FROM routes;
SELECT COUNT(*) AS pass_count FROM bus_passes;
