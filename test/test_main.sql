USE _;

-- test _.is_trx_in_progress()
CREATE TABLE t (x INT UNSIGNED NOT NULL) ENGINE InnoDB;
START TRANSACTION;
INSERT INTO t VALUES (1);
SELECT 'Expect: 1' AS message;
SELECT _.is_trx_in_progress();
COMMIT;
DROP TABLE t;
SELECT 'Expect: 0' AS message;
SELECT _.is_trx_in_progress();

-- test _.get_current_trx_id()
CREATE TABLE t (x INT UNSIGNED NOT NULL) ENGINE InnoDB;
START TRANSACTION;
INSERT INTO t VALUES (1);
SELECT 'Expect: id' AS message;
SELECT _.get_current_trx_id();
COMMIT;
DROP TABLE t;
SELECT 'Expect: NULL' AS message;
SELECT _.get_current_trx_id();

-- test _.record_current_trx_id()
CREATE TABLE t (x INT UNSIGNED NOT NULL) ENGINE InnoDB;
START TRANSACTION;
INSERT INTO t VALUES (1);
CALL _.record_current_trx_id('Test', @trx_id);
SELECT 'Expect: 1 row' AS message;
SELECT @last_trx_id := trx_id, trx_timestamp, event
    FROM _.trx_history
    ORDER BY trx_timestamp DESC
    LIMIT 1
;
SELECT 'Expect: 1' AS message;
SELECT @trx_id = @last_trx_id;
-- cleanup
SET @trx_id := NULL;
SET @last_trx_id := NULL;
COMMIT;

