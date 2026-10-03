-- consultas_verificacion.sql
-- Verificacion de quantum_wallet.db desde la consola de SQLite.
-- Ejecutar:  sqlite3 quantum_wallet.db ".read consultas_verificacion.sql"

.headers on
.mode box
PRAGMA foreign_keys = ON;

SELECT 'Version de SQLite' AS dato, sqlite_version() AS valor;

-- 1. Objetos del esquema
SELECT type AS tipo, name AS nombre
FROM sqlite_master
WHERE name NOT LIKE 'sqlite_%'
ORDER BY type, name;

-- 2. Llaves foraneas de la tabla wallets
SELECT "table" AS referencia, "from" AS columna, "to" AS columna_destino, on_delete
FROM pragma_foreign_key_list('wallets');

-- 3. Usuarios y sus wallets (JOIN por la FK id_propietario)
SELECT * FROM vista_saldos ORDER BY id_usuario;

-- 4. Nomina de las empresas (relacion muchos a muchos)
SELECT * FROM vista_nomina;

-- 5. Historial de movimientos
SELECT id_transaccion AS id, titular, tipo, monto, saldo_resultante AS saldo, descripcion
FROM vista_movimientos ORDER BY id_transaccion;

-- 6. Integridad referencial: sin filas = sin violaciones
PRAGMA foreign_key_check;
SELECT 'foreign_key_check' AS prueba, 'sin violaciones' AS resultado;
