-- MariaDB 5.3

USE _;

DELIMITER ||

-- Overwrite generic implementation,
-- as MariaDB exposes a variable for this.
DROP FUNCTION IF EXISTS is_trx_in_progress;
CREATE FUNCTION is_trx_in_progress()
    RETURNS BOOL
    NOT DETERMINISTIC
    READS SQL DATA
    COMMENT 'Return wether a transaction is in progress'
BEGIN
    RETURN @@session.in_transaction;
END ||

DELIMITER ;

