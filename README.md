# Semana 7 · Actividad 1 — Arquitectura de bases de datos: persistencia de la Quantum Wallet

Esquema relacional en **SQLite** construido a partir del diagrama de clases UML de `usuarios.py`
(Semana 6). El script `configurar_db.py` crea la base `quantum_wallet.db`, inserta datos de prueba
y verifica las restricciones de integridad.

El trabajo parte del código original de la actividad (enunciado de Canvas y repositorio del curso):
tablas `usuarios` y `wallets`, llave primaria, llave foránea `id_propietario` y saldo `REAL`. Todo
eso se conserva. Para enriquecer el ejercicio se **adicionaron** columnas, cuatro tablas, índices,
vistas y triggers, de modo que el esquema cubra todas las clases del modelo UML.

![Modelo entidad-relación de la Quantum Wallet](diagrama_er_quantum_wallet.png)

## Archivos

| Archivo | Contenido |
|---|---|
| `configurar_db.py` | Crea el esquema, inserta los datos de prueba y ejecuta las verificaciones |
| `quantum_wallet.db` | Base de datos SQLite generada por el script |
| `consultas_verificacion.sql` | Consultas de comprobación para la consola de SQLite |
| `generar_excel.py` | Genera `carga_masiva_quantum.xlsx` con 560 registros simulados |
| `importar_excel.py` | Carga masiva del Excel hacia `quantum_wallet.db` |
| `carga_masiva_quantum.xlsx` | Archivo de carga: hojas `usuarios` (60) y `movimientos` (500) |
| `errores_importacion.log` / `resultado_importacion.xlsx` | Rechazos de la importación con hoja, fila y motivo |
| `diagrama_er_quantum_wallet.drawio` | Modelo entidad-relación editable (Draw.io Integration en VS Code) |
| `diagrama_er_quantum_wallet.png` / `.svg` | Exportaciones del modelo |
| `capturas/` | Evidencias de la instalación, la ejecución y la verificación |
| `Semana7_Actividad1_Bases_de_Datos_Deibis_Zuluaga.pdf` | Informe técnico |

## Del modelo de clases a las tablas

| Clase (Semana 6) | Tabla | Origen | Relación |
|---|---|---|---|
| `Usuario`, `UsuarioEmpresa` | `usuarios` | Original, ampliada | Jerarquía en una tabla con `tipo_usuario` |
| `Wallet` | `wallets` | Original, ampliada | Composición `usuarios` 1 : 1 `wallets` |
| `Transaccion` | `transacciones` | **Adicionada** | Composición `wallets` 1 : N `transacciones` |
| `Empleado` | `empleados` | **Adicionada** | Herencia: la PK también es FK a `usuarios` |
| `UsuarioEmpresa ◇ Empleado` | `vinculaciones` | **Adicionada** | Agregación N : M con llave primaria compuesta |
| `BancoCentral` (Singleton) | `configuracion_sistema` | **Adicionada** | Una sola fila permitida (`CHECK (id = 1)`) |

## Columnas por tabla

| Tabla | Columnas del código original | Columnas adicionadas |
|---|---|---|
| `usuarios` | `id_usuario` (PK), `nombre`, `email`, `nit` | `tipo_usuario`, `cedula`, `fecha_registro` |
| `wallets` | `id_wallet` (PK), `saldo` REAL, `id_propietario` (FK) | `codigo`, `moneda`, `fecha_creacion` |
| `transacciones` | — | `id_transaccion` (PK), `id_wallet` (FK), `tipo`, `monto`, `saldo_resultante`, `id_wallet_contraparte` (FK), `descripcion`, `fecha` |
| `empleados` | — | `id_usuario` (PK y FK), `cargo`, `salario` |
| `vinculaciones` | — | `id_empresa` y `id_empleado` (PK compuesta, ambas FK), `fecha_vinculacion` |
| `configuracion_sistema` | — | `id` (PK), `moneda`, `limite_transaccion`, `fondos_totales`, `reservas` |

## Restricciones de integridad

| Restricción | Regla que protege |
|---|---|
| `FOREIGN KEY ... ON DELETE CASCADE` | Al borrar un usuario se borran su wallet y su historial (composición) |
| `UNIQUE (id_propietario)` | Un usuario no puede tener dos wallets (1 : 1) |
| `CHECK (saldo >= 0)` | Ningún pago deja la wallet en negativo |
| `CHECK` sobre `tipo_usuario` y `nit` | Solo las empresas tienen NIT y toda empresa lo tiene |
| `UNIQUE` en `email`, `cedula`, `nit` | No se repiten identificaciones |
| `trg_usuario_crea_wallet` | Cada usuario nuevo recibe su wallet, como en `Usuario.__init__()` |
| `trg_transaccion_valida_limite` | Equivale a `BancoCentral.validar_monto()` |
| `trg_empleado_valida_tipo`, `trg_vinculacion_valida_empresa` | Solo empleados tienen ficha y solo empresas vinculan |

> **Llaves foráneas en SQLite**
> SQLite trae la verificación de llaves foráneas apagada. `configurar_db.py` ejecuta
> `PRAGMA foreign_keys = ON;` en cada conexión; sin esa línea las FK no se validan.

## Requisitos

| Componente | Versión utilizada | Uso |
|---|---|---|
| Python 3 y módulo `sqlite3` | Python 3.14.7 · SQLite 3.50.4 | Crea y llena la base desde `configurar_db.py` (el módulo viene incluido) |
| Consola `sqlite3` | SQLite 3.43.2 (incluida en macOS) | Consultas desde la Terminal |
| DB Browser for SQLite | Aplicación de escritorio | Visualización de la estructura y los datos |
| `openpyxl` | 3.1.5 | Lectura y escritura de Excel (`python3 -m pip install openpyxl`) |

```bash
sqlite3 --version
python3 -c "import sqlite3; print('SQLite listo para Python -', sqlite3.sqlite_version)"
```

## Cómo ejecutar

```bash
python3 configurar_db.py
```

El script borra y vuelve a crear `quantum_wallet.db`, de modo que se puede ejecutar las veces
que sea necesario.

**Salida esperada (resumida):**

```
[2] Estructura creada
    Tablas (6): configuracion_sistema, empleados, transacciones, usuarios, vinculaciones, wallets
    Indices (2) · Triggers (4) · Vistas (3)

[3] Datos de prueba
      1  Ana Torres   PERSONA   W-00001       220,000.50 COP
      2  Bancolombia  EMPRESA   W-00002       300,000.00 COP
      3  Quantum SAS  EMPRESA   W-00003     2,300,000.00 COP
      4  Laura Gomez  EMPLEADO  W-00004     4,349,999.50 COP
      5  Pedro Rios   EMPLEADO  W-00005     3,200,000.00 COP
    Conciliacion saldo vs. historial: correcta en todas las wallets

[4] Pruebas de integridad (todas deben ser RECHAZADAS)
    Resultado: 8 de 8 operaciones invalidas rechazadas

[5] AUTOINCREMENT y borrado en cascada
    Se creo y se borro el usuario 6; wallets huerfanas: 0
    El siguiente usuario recibio el id 7 (el 6 no se reutiliza)
```

## Verificación desde la consola de SQLite

```bash
sqlite3 quantum_wallet.db ".read consultas_verificacion.sql"
```

Muestra la versión de SQLite, los objetos del esquema, las llaves foráneas de `wallets`, los
saldos, la nómina, el historial de movimientos y el resultado de `PRAGMA foreign_key_check`.

## Visualización

En **DB Browser for SQLite**: *Open Database* → `quantum_wallet.db`. La pestaña
*Database Structure* muestra tablas, índices, vistas y triggers, y *Browse Data* el contenido de
cada tabla. Las capturas de la verificación están en la carpeta `capturas/`.

> **Tabla `sqlite_sequence`**
> DB Browser lista siete tablas porque incluye `sqlite_sequence`, tabla interna que SQLite crea al
> usar `AUTOINCREMENT` para guardar el último id asignado.

## Mejora: carga masiva desde Excel

Importa en bloque usuarios y movimientos desde Excel. Cada fila pasa por las mismas funciones,
restricciones y triggers del sistema; las filas inválidas se rechazan y quedan documentadas.

```bash
python3 -m pip install openpyxl     # una sola vez
python3 configurar_db.py            # base limpia
python3 generar_excel.py            # crea carga_masiva_quantum.xlsx
python3 importar_excel.py           # importa el Excel
```

| Característica | Implementación |
|---|---|
| Datos simulados | 33 personas, 9 empresas, 14 empleados y 500 movimientos de septiembre de 2026 (semilla fija) |
| Errores intencionales | 29 filas (5 %): saldo insuficiente, monto negativo, límite, documento inexistente, fecha inválida, tipo no válido, duplicados |
| Atomicidad | Cada fila se importa completa o no se importa |
| Orden de dependencias | Los empleados se cargan después de sus empresas |
| Trazabilidad | `errores_importacion.log` (modo agregar) y `resultado_importacion.xlsx` |
| Control de duplicados | Huella SHA-256 del archivo en la tabla `importaciones` |

**Salida esperada:**

```
    Hoja           Leidas  Importadas  Rechazadas
    usuarios           60          56           4
    movimientos       500         475          25
    TOTAL             560         531          29
    ...
      Transacciones registradas : 590 (579 nuevas)
      Conciliacion de saldos    : correcta en todas las wallets
```

> **Importación repetida**
> Si se ejecuta de nuevo `importar_excel.py` con el mismo archivo, la carga se rechaza
> (`CARGA RECHAZADA: este archivo ya se importo`). Para repetir la prueba, ejecute antes
> `configurar_db.py`.
