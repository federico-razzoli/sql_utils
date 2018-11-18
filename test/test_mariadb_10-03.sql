USE _;

CREATE TABLE IF NOT EXISTS test_table (x INT UNSIGNED NOT NULL) ENGINE InnoDB;
CALL _.add_system_versioning('_', 'test_table', 'valid_from', 'valid_to');
INSERT INTO test_table (x) VALUES (1);
DELETE FROM test_table WHERE x = 1;
SELECT
        '<timestamp(6)>,<timestamp(6)>,1' AS expect,
        valid_from,
        valid_to,
        x
    FROM test_table FOR SYSTEM_TIME ALL
;
DROP TABLE test_table;

