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

-- test _.is_system_versioned()
CREATE OR REPLACE TABLE _.not_sysver (x INT UNSIGNED NOT NULL) ENGINE InnoDB;
CREATE OR REPLACE TABLE _.sysver     (x INT UNSIGNED NOT NULL) ENGINE InnoDB
    WITH SYSTEM VERSIONING;
SELECT
    '0,1,<NULL>' AS 'expect',
    _.is_system_versioned('_', 'not_sysver'),
    _.is_system_versioned('_', 'sysver'),
    _.is_system_versioned('_', 'not_exists')
;
DROP TABLE _.not_sysver, _.sysver;

