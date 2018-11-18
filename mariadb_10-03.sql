 -- MariaDB 10.3

USE _;

DELIMITER ||

DROP PROCEDURE IF EXISTS add_system_versioning;
CREATE PROCEDURE add_system_versioning(
    in_database VARCHAR(64),
    in_table VARCHAR(64),
    in_start_column VARCHAR(64),
    in_end_column VARCHAR(64),
    in_type ENUM('time', 'trx')
)
    MODIFIES SQL DATA
    COMMENT 'Make an existing table system-versioned'
BEGIN
    DECLARE v_alter_table TEXT DEFAULT NULL;
    DECLARE v_type TEXT DEFAULT NULL;
SET in_type := UPPER(in_type);
    IF in_type LIKE 'TIME%' THEN
        SET v_type := 'TIMESTAMP(6)';
    ELSEIF in_type IN ('TRX', 'TRANSACTION') THEN
        SET v_type := 'BIGINT UNSIGNED';
    END IF;
    SET v_alter_table := CONCAT('
    ALTER TABLE ', _.quote_name2(in_database, in_table), '
        ADD COLUMN ',  in_start_column , ' ', v_type, ' GENERATED ALWAYS AS ROW START,
        ADD COLUMN ',  in_end_column   , ' ', v_type, ' GENERATED ALWAYS AS ROW END,
        ADD PERIOD FOR SYSTEM_TIME(', in_start_column, ', ', in_end_column, '),
        ADD SYSTEM VERSIONING
    ;');
    CALL run_sql(v_alter_table);
END ||

DROP FUNCTION IF EXISTS is_system_versioned;
CREATE FUNCTION is_system_versioned(p_database VARCHAR(64), p_table VARCHAR(64))
    RETURNS BOOL
    NOT DETERMINISTIC
    READS SQL DATA
    COMMENT 'Return whether the specified table is system-versioned, NULL if it was not found'
BEGIN
    DECLARE r BOOL DEFAULT NULL;
    SET r := (
        SELECT TABLE_TYPE = 'SYSTEM VERSIONED'
            FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = p_database AND TABLE_NAME = p_table
    );
    RETURN r;
END ||

DELIMITER ;

