USE _;

-- test _.add_system_versioning()
CREATE OR REPLACE TABLE test_table (x INT UNSIGNED NOT NULL) ENGINE InnoDB;
CALL _.add_system_versioning('_', 'test_table', 'valid_from', 'valid_to', 'time');
INSERT INTO test_table (x) VALUES (1);
DELETE FROM test_table WHERE x = 1;
SELECT
        '<timestamp(6)>,<timestamp(6)>,1' AS expect,
        valid_from,
        valid_to,
        x
    FROM test_table FOR SYSTEM_TIME ALL
;
CREATE OR REPLACE TABLE test_table (x INT UNSIGNED NOT NULL) ENGINE InnoDB;
CALL _.add_system_versioning('_', 'test_table', 'valid_from', 'valid_to', 'trx');
INSERT INTO test_table (x) VALUES (1);
DELETE FROM test_table WHERE x = 1;
SELECT
        '<bigint>,<bigint>,1' AS expect,
        valid_from,
        valid_to,
        x
    FROM test_table FOR SYSTEM_TIME ALL
;
DROP TABLE test_table;

-- test _.is_system_versioned_table(), _.drop_system_versioning(), is_temporal_table()
-- test with implicit temporal columns
CREATE OR REPLACE TABLE _.test_sysver (x INT UNSIGNED NOT NULL) ENGINE InnoDB
    WITH SYSTEM VERSIONING;
SELECT
    '1,1,<NULL>,<NULL>' AS 'expect',
    _.is_system_versioned_table( '_', 'test_sysver' ),
    _.is_temporal_table(         '_', 'test_sysver' ),
    _.is_system_versioned_table( '_', 'not_exists'  ),
    _.is_temporal_table(         '_', 'not_exists'  )
;
CALL _.drop_system_versioning('_', 'test_sysver');
SELECT
    '0,0' AS 'expect',
    _.is_system_versioned_table( '_', 'test_sysver' ),
    _.is_temporal_table(         '_', 'test_sysver' )
;
-- test with explicitally defined temporal columns
CREATE OR REPLACE TABLE _.test_sysver (
    x INT UNSIGNED NOT NULL,
    valid_from TIMESTAMP(6) GENERATED ALWAYS AS ROW START,
    valid_to TIMESTAMP(6) GENERATED ALWAYS AS ROW END,
    PERIOD FOR SYSTEM_TIME(valid_from, valid_to)
)
    ENGINE InnoDB
    WITH SYSTEM VERSIONING
;
SELECT
    '1,1' AS 'expect',
    _.is_system_versioned_table( '_', 'test_sysver' ),
    _.is_temporal_table(         '_', 'test_sysver' )
;
CALL _.drop_system_versioning('_', 'test_sysver');
SELECT
    '0,0' AS 'expect',
    _.is_system_versioned_table( '_', 'test_sysver' ),
    _.is_temporal_table(         '_', 'test_sysver' )
;
DROP TABLE _.test_sysver;

-- test _.TEMPORAL_TABLES, _.SYSTEM_VERSIONED_TABLES
-- Test the correctness of HAS_TEMPORAL_COLUMNS column.
-- Implicitly, we will also test the table itself.
CREATE OR REPLACE TABLE _.test_sysver (
    x INT UNSIGNED NOT NULL,
    valid_from TIMESTAMP(6) GENERATED ALWAYS AS ROW START,
    valid_to TIMESTAMP(6) GENERATED ALWAYS AS ROW END,
    PERIOD FOR SYSTEM_TIME(valid_from, valid_to)
)
    ENGINE InnoDB
    WITH SYSTEM VERSIONING
;
SELECT
    '1,1' AS 'expect',
    (SELECT HAS_TEMPORAL_COLUMNS
        FROM _.TEMPORAL_TABLES
        WHERE TABLE_SCHEMA = '_' AND TABLE_NAME = 'test_sysver'),
    (SELECT HAS_TEMPORAL_COLUMNS
        FROM _.SYSTEM_VERSIONED_TABLES
        WHERE TABLE_SCHEMA = '_' AND TABLE_NAME = 'test_sysver')
;
CREATE OR REPLACE TABLE _.test_sysver (x INT UNSIGNED NOT NULL) ENGINE InnoDB
    WITH SYSTEM VERSIONING;
SELECT
    '0,0' AS 'expect',
    (SELECT HAS_TEMPORAL_COLUMNS
        FROM _.TEMPORAL_TABLES
        WHERE TABLE_SCHEMA = '_' AND TABLE_NAME = 'test_sysver'),
    (SELECT HAS_TEMPORAL_COLUMNS
        FROM _.SYSTEM_VERSIONED_TABLES
        WHERE TABLE_SCHEMA = '_' AND TABLE_NAME = 'test_sysver')
;
DROP TABLE _.test_sysver;

-- test _.TEMPORAL_COLUMNS
CREATE OR REPLACE TABLE _.test_sysver (
    x INT UNSIGNED NOT NULL,
    valid_from TIMESTAMP(6) GENERATED ALWAYS AS ROW START,
    valid_to TIMESTAMP(6) GENERATED ALWAYS AS ROW END,
    PERIOD FOR SYSTEM_TIME(valid_from, valid_to)
)
    ENGINE InnoDB
    WITH SYSTEM VERSIONING
;
SELECT
    2 AS 'expect',
    (SELECT COUNT(*)
        FROM _.TEMPORAL_COLUMNS
        WHERE TABLE_SCHEMA = '_' AND TABLE_NAME = 'test_sysver')
;

