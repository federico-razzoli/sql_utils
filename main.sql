-- This file can be executed on any reasonably recent version of MySQL or MariaDB.
-- Some of the routines may be overwritten when executing more specific files.

CREATE DATABASE IF NOT EXISTS _;
USE _;


/*
    Generic Routines
    ================
*/

DELIMITER ||

DROP PROCEDURE IF EXISTS run_sql;
CREATE PROCEDURE run_sql(IN in_sql TEXT)
    MODIFIES SQL DATA
    COMMENT 'Run specified SQL query. Cannot be called recursively'
BEGIN
    SET @_run_sql_sql = in_sql;
    PREPARE _stmt_run_sql_sql FROM @_run_sql_sql;
    
    EXECUTE _stmt_run_sql_sql;

    DEALLOCATE PREPARE _stmt_run_sql_sql;
    SET @_run_sql_sql = NULL;
END ||

DELIMITER ;


/*
    Current Transaction
    ===================
*/

DELIMITER ||

DROP FUNCTION IF EXISTS is_trx_in_progress;
CREATE FUNCTION is_trx_in_progress()
    RETURNS BOOL
    NOT DETERMINISTIC
    READS SQL DATA
    COMMENT 'Return wether a transaction is in progress'
BEGIN
    RETURN EXISTS (
        SELECT TRX_ID
            FROM information_schema.INNODB_TRX
            WHERE TRX_MYSQL_THREAD_ID = CONNECTION_ID()
    );
END ||

DROP FUNCTION IF EXISTS get_current_trx_id;
CREATE FUNCTION get_current_trx_id()
    RETURNS BIGINT UNSIGNED
    NOT DETERMINISTIC
    READS SQL DATA
    COMMENT 'Return the id of current transaction'
BEGIN
    RETURN (
        SELECT TRX_ID
            FROM information_schema.INNODB_TRX
            WHERE TRX_MYSQL_THREAD_ID = CONNECTION_ID()
    );
END ||

DROP TABLE IF EXISTS trx_history;
CREATE TABLE trx_history (
    trx_id BIGINT UNSIGNED NOT NULL,
    trx_timestamp TIMESTAMP(6) NOT NULL,
    event VARCHAR(50) NOT NULL,
    PRIMARY KEY (trx_id, trx_timestamp)
)
    ENGINE InnoDB,
    COMMENT 'History of transaction ids and time'
||

DROP PROCEDURE IF EXISTS record_current_trx_id;
CREATE PROCEDURE record_current_trx_id(
        IN in_event VARCHAR(50),
        OUT out_trx_id BIGINT UNSIGNED
    )
    MODIFIES SQL DATA
    COMMENT 'Write the id of current transaction into _.trx_history'
BEGIN
    DECLARE v_trx_id BIGINT UNSIGNED
        DEFAULT _.get_current_trx_id();
    INSERT INTO trx_history
            (trx_id, trx_timestamp, event)
        VALUES
            (v_trx_id, NOW(6), in_event);
    SET out_trx_id := v_trx_id;
END ||

DELIMITER ;

