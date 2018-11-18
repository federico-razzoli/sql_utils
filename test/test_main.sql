USE _;

-- DROP/CREATE objects used for tests
SELECT 'Possible warnings expected'  AS message;
DROP TABLE IF EXISTS t;
SELECT 'End of expected warnings'    AS message;

-- test _.quote_name()
SELECT
    '`a``b`' AS expect,
    _.quote_name('a`b')
        AS result
;
SELECT
    '<NULL>' AS expect,
    _.quote_name(NULL)
        AS result
;

-- test _.quote_name2()
SELECT
    '`a``b`.`c``d`' AS expect,
    _.quote_name2('a`b', 'c`d')
        AS result
;
SELECT
    '<NULL>' AS expect,
    _.quote_name2(NULL, 'x')
        AS result
;
SELECT
    '<NULL>' AS expect,
    _.quote_name2('x', NULL)
        AS result
;
SELECT
    '<NULL>' AS expect,
    _.quote_name2(NULL, NULL)
        AS result
;

-- test _.quote_name3()
SELECT
    '`a``b`.`c``d`.`e``f`' AS expect,
    _.quote_name3('a`b', 'c`d', 'e`f')
        AS result
;
SELECT
    '<NULL>' AS expect,
    _.quote_name3(NULL, 'x', 'x')
        AS result
;
SELECT
    '<NULL>' AS expect,
    _.quote_name3('x', NULL, 'x')
        AS result
;
SELECT
    '<NULL>' AS expect,
    _.quote_name3(NULL, NULL, 'x')
        AS result
;

-- test _.run_sql()
CREATE TABLE t (x INT UNSIGNED NOT NULL) ENGINE InnoDB;
CALL _.run_sql('INSERT INTO t VALUES (24);');
SELECT
    1 AS expect,
    EXISTS (SELECT x FROM t WHERE x = 24)
        AS result
;
DROP TABLE t;

-- test _.is_trx_in_progress()
CREATE TABLE t (x INT UNSIGNED NOT NULL) ENGINE InnoDB;
START TRANSACTION;
INSERT INTO t VALUES (1);
SELECT
    1 AS expect,
    _.is_trx_in_progress()
        AS result
;
COMMIT;
DROP TABLE t;
SELECT
    0 AS result,
    _.is_trx_in_progress()
        AS result
;

-- test _.get_current_trx_id()
CREATE TABLE t (x INT UNSIGNED NOT NULL) ENGINE InnoDB;
START TRANSACTION;
INSERT INTO t VALUES (1);
SELECT
    '<int>' AS expect,
    _.get_current_trx_id()
        AS result
;
COMMIT;
DROP TABLE t;
SELECT
    '<NULL>' AS expect,
    _.get_current_trx_id()
        AS result
;

-- test _.record_current_trx_id()
CREATE TABLE t (x INT UNSIGNED NOT NULL) ENGINE InnoDB;
START TRANSACTION;
INSERT INTO t VALUES (1);
CALL _.record_current_trx_id('Test', @trx_id);
SELECT
    '<int>,<timestamp(6)>,<string>'
        AS expect;
SELECT @last_trx_id := trx_id, trx_timestamp, event
    FROM _.trx_history
    ORDER BY trx_timestamp DESC
    LIMIT 1
;
SELECT
    1 AS expect,
    @trx_id = @last_trx_id
        AS result
;
-- cleanup
SET @trx_id := NULL;
SET @last_trx_id := NULL;
COMMIT;
DROP TABLE t;

