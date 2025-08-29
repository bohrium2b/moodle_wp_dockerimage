CREATE DATABASE IF NOT EXISTS moodle_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'moodle_user'@'%' IDENTIFIED BY 'moodle_pw';
GRANT ALL PRIVILEGES ON moodle_db.* TO 'moodle_user'@'%';
FLUSH PRIVILEGES;