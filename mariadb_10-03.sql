 -- MariaDB 10.3

USE _;

DELIMITER ||

DROP PROCEDURE IF EXISTS add_system_versioning;
CREATE PROCEDURE add_system_versioning(
    in_database VARCHAR(64),
    in_table VARCHAR(64),
    in_start_column VARCHAR(64),
    in_end_column VARCHAR(64)
)
    MODIFIES SQL DATA
    COMMENT 'Make an existing table system-versioned'
BEGIN
    DECLARE alter_table TEXT;
    SET alter_table := CONCAT('
    ALTER TABLE ', _.quote_name2(in_database, in_table), '
        ADD COLUMN ',  in_start_column , ' TIMESTAMP(6) GENERATED ALWAYS AS ROW START,
        ADD COLUMN ',  in_end_column   , ' TIMESTAMP(6) GENERATED ALWAYS AS ROW END,
        ADD PERIOD FOR SYSTEM_TIME(', in_start_column, ', ', in_end_column, '),
        ADD SYSTEM VERSIONING
    ;');
    CALL run_sql(alter_table);
END ||

DELIMITER ;

