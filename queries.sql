-- ================================================
-- ANÁLISIS DEL DESEMPEÑO FINANCIERO
-- Adventure Works 2017
-- Autora: Alison Ixchel Maertens Gaona
-- Herramienta: SQL (replicable en SQLiteOnline)
-- ================================================


-- ================================================
-- PARTE 1: EXPLORACIÓN DEL ESQUEMA
-- Objetivo: Conocer la estructura de cada tabla e identificar claves de unión
-- ================================================

SELECT * FROM ventas_2017         LIMIT 10;
SELECT * FROM productos           LIMIT 10;
SELECT * FROM productos_categorias LIMIT 10;
SELECT * FROM territorios         LIMIT 10;
SELECT * FROM campanas            LIMIT 10;

-- Claves de unión identificadas:
-- ventas_2017   → clave_producto, clave_territorio
-- productos     → clave_producto, clave_subcategoria
-- productos_categorias → clave_subcategoria, clave_categoria
-- territorios   → clave_territorio
-- campanas      → clave_territorio


-- ================================================
-- PARTE 2: EXTRACCIÓN Y LIMPIEZA DE DATOS
-- Objetivo: Construir tabla base combinando ventas, productos y territorios. Manejar NULLs.
-- ================================================

-- Paso 1: Exploración de joins y tratamiento de nulos
SELECT 
    v.clave_territorio, 
    t.pais,
    t.continente,
    v.numero_pedido        AS pedido_id,
    v.clave_producto       AS producto_id,
    p.nombre_producto      AS producto,
    pc.clave_categoria     AS categoria,
    COALESCE(v.cantidad_pedido, 0), 
    COALESCE(p.costo_producto, 0)  AS costo,
    COALESCE(p.precio_producto, 0) AS precio
FROM ventas_2017 v
LEFT JOIN productos p 
    ON v.clave_producto = p.clave_producto
LEFT JOIN productos_categorias pc 
    ON p.clave_subcategoria = pc.clave_subcategoria
LEFT JOIN territorios t 
    ON v.clave_territorio = t.clave_territorio;

-- Paso 2: Tabla base con columnas calculadas
--         ingreso_total = precio × cantidad
--         costo_total   = costo  × cantidad
SELECT
    v.numero_pedido,
    v.clave_producto,
    p.nombre_producto,
    pc.clave_categoria,
    COALESCE(p.precio_producto, 0) AS precio_producto,
    COALESCE(v.cantidad_pedido, 0) AS cantidad_pedido,
    COALESCE(p.costo_producto, 0)  AS costo_producto,
    t.pais,
    t.continente,
    v.clave_territorio,
    COALESCE(p.precio_producto, 0) * COALESCE(v.cantidad_pedido, 0) AS ingreso_total,
    COALESCE(p.costo_producto, 0)  * COALESCE(v.cantidad_pedido, 0) AS costo_total
FROM ventas_2017 AS v
JOIN productos AS p
    ON v.clave_producto = p.clave_producto
LEFT JOIN productos_categorias AS pc
    ON p.clave_subcategoria = pc.clave_subcategoria
LEFT JOIN territorios AS t
    ON v.clave_territorio = t.clave_territorio;
-- Vista guardada como: ventas_clean


-- ================================================
-- PARTE 3: CÁLCULO DE KPIs FINANCIEROS
-- Objetivo: Beneficio Bruto, Margen % y ROI % por país y territorio
-- ================================================

-- Paso 1: Ingresos y costos por país
SELECT 
    pais,
    clave_territorio,
    SUM(ingreso_total)::integer AS ingresos,
    SUM(costo_total)::integer   AS costos
FROM ventas_clean
GROUP BY pais, clave_territorio
ORDER BY ingresos DESC;
-- Vista guardada como: pais_ingreso_costo

-- Paso 2: Agregar inversión en campañas de marketing
SELECT
    v.pais,
    v.clave_territorio,
    SUM(v.ingreso_total)::integer              AS ingresos,
    SUM(v.costo_total)::integer                AS costos,
    COALESCE(SUM(c.costo_campana::integer), 0) AS costo_campana
FROM ventas_clean AS v
LEFT JOIN campanas AS c
    ON v.clave_territorio = c.clave_territorio::integer
GROUP BY v.pais, v.clave_territorio
ORDER BY ingresos DESC;
-- Vista guardada como: pais_campanas

-- Paso 3: Beneficio Bruto, Margen % y ROI %
SELECT
    p.pais,
    p.clave_territorio,
    SUM(p.ingresos)::integer                          AS ingresos,
    SUM(p.costos)::integer                            AS costos,
    COALESCE(SUM(c.costo_campana), 0)::integer        AS costo_campana,
    SUM(p.ingresos)::integer - SUM(p.costos)::integer AS beneficio_bruto,
    (SUM(p.ingresos) - SUM(p.costos)) * 100.0
        / SUM(p.ingresos)                             AS margen_pct,
    (SUM(p.ingresos) - SUM(p.costos)) * 100.0
        / NULLIF(SUM(c.costo_campana), 0)             AS roi_pct
FROM pais_ingreso_costo AS p
LEFT JOIN pais_campanas AS c
    ON p.clave_territorio = c.clave_territorio
GROUP BY p.pais, p.clave_territorio
ORDER BY p.clave_territorio, ingresos, costos;


-- ================================================
-- PARTE 4: VALIDACIÓN Y CONTROL DE CALIDAD (QA)
-- Objetivo: Verificar integridad de datos antes de presentar resultados
-- ================================================

-- Paso 1: Detectar NULLs en claves críticas
SELECT 
    SUM(CASE WHEN numero_pedido    IS NULL THEN 1 ELSE 0 END) AS nulos_numero_pedido,
    SUM(CASE WHEN clave_producto   IS NULL THEN 1 ELSE 0 END) AS nulos_clave_producto,
    SUM(CASE WHEN clave_territorio IS NULL THEN 1 ELSE 0 END) AS nulos_clave_territorio
FROM ventas_2017;

-- Paso 2: Detectar cantidades no válidas (≤ 0)
SELECT 
    COUNT(cantidad_pedido) AS filas_cantidad_no_valida
FROM ventas_2017
WHERE cantidad_pedido <= 0;

-- Paso 3: Detectar precios negativos en catálogo
SELECT 
    COUNT(precio_producto) AS producto_precio_no_valido
FROM productos
WHERE precio_producto < 0;
