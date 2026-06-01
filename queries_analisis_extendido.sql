-- ================================================
-- ANÁLISIS EXTENDIDO - PREGUNTAS ADICIONALES
-- Adventure Works 2017
-- Autora: Alison Ixchel Maertens Gaona
-- Nota: Queries desarrolladas en SQLiteOnline
--       (sintaxis SQLite: CAST, IFNULL)
-- ================================================


-- ================================================
-- PREGUNTA 1: ¿Qué productos son los más rentables?
-- Objetivo: Calcular beneficio bruto y % de margen por producto y categoría
-- ================================================

SELECT 
    v.clave_producto                                                    AS producto_id,
    p.nombre_producto                                                   AS producto,
    pc.clave_categoria                                                  AS categoria,
    COALESCE(p.costo_producto, 0)                                       AS costo,
    COALESCE(p.precio_producto, 0)                                      AS precio,
    (COALESCE(p.precio_producto, 0) - COALESCE(p.costo_producto, 0))    AS beneficio_bruto,
    (COALESCE(p.precio_producto, 0) - COALESCE(p.costo_producto, 0))
        / NULLIF(p.precio_producto, 0)                                  AS pct_beneficio
FROM ventas_2017 v
LEFT JOIN productos p 
    ON v.clave_producto = p.clave_producto
LEFT JOIN productos_categorias pc 
    ON p.clave_subcategoria = pc.clave_subcategoria
GROUP BY 
    v.clave_producto,
    p.nombre_producto,
    pc.clave_categoria;


-- ================================================
-- PREGUNTA 2: ¿Existen territorios con gasto de marketing ineficiente?
-- Objetivo: Comparar ingresos vs costo de campañas por país y territorio
-- ================================================

-- Versión final funcional en SQLite
-- (iteraciones anteriores resuelven compatibilidad de tipos entre ventas_clean y campanas)
SELECT
    v.pais,
    CAST(v.clave_territorio AS INT)                            AS clave_territorio,
    CAST(SUM(v.ingreso_total) AS INT)                          AS ingresos,
    CAST(SUM(v.costo_total) AS INT)                            AS costos,
    CAST(COALESCE(c.total_campana, 0) AS INT)                  AS costo_campana,
    CAST(SUM(v.ingreso_total) - SUM(v.costo_total) AS INT)     AS beneficio_bruto,
    (SUM(v.ingreso_total) - SUM(v.costo_total)) * 100.0
        / NULLIF(SUM(v.ingreso_total), 0)                      AS margen_pct,
    (SUM(v.ingreso_total) - SUM(v.costo_total)) * 100.0
        / NULLIF(c.total_campana, 0)                           AS roi_pct
FROM ventas_clean AS v
LEFT JOIN (
    SELECT 
        CAST(clave_territorio AS INT) AS clave_territorio,
        SUM(costo_campana)            AS total_campana
    FROM campanas
    GROUP BY CAST(clave_territorio AS INT)
) AS c ON CAST(v.clave_territorio AS INT) = c.clave_territorio
GROUP BY
    v.pais,
    CAST(v.clave_territorio AS INT)
ORDER BY
    clave_territorio, ingresos, costos;


-- ================================================
-- PREGUNTA 3: ¿Qué continentes ofrecen la mejor oportunidad de inversión?
-- Objetivo: Agrupar países por continente y calcular margen y ROI consolidados
-- Nota: Se usaron valores reales obtenidos del análisis por país como subconsulta base
-- ================================================

SELECT 
    CASE 
        WHEN p.pais IN ('United States', 'Canada')            THEN 'Norteamérica'
        WHEN p.pais IN ('United Kingdom', 'France', 'Germany') THEN 'Europa'
        WHEN p.pais = 'Australia'                              THEN 'Oceanía'
    END                                                              AS continente,
    SUM(p.ingresos)                                                  AS ingresos_totales,
    SUM(p.beneficio_bruto)                                           AS beneficio_bruto_total,
    (SUM(p.ingresos) - SUM(p.costos)) * 100.0
        / SUM(p.ingresos)                                            AS margen_promedio_pct,
    SUM(p.beneficio_bruto) * 100.0
        / NULLIF(SUM(p.costo_campana), 0)                            AS roi_marketing_pct
FROM (
    -- Valores reales por país extraídos del análisis previo
    SELECT 'United States' AS pais, 3353940 AS ingresos, 1899471 AS costos, 1920000 AS costo_campana, 1454469 AS beneficio_bruto UNION ALL
    SELECT 'United Kingdom',        1189637,              681509,            2304000,                  508128  UNION ALL
    SELECT 'Canada',                 710205,              392326,            1824000,                  317879  UNION ALL
    SELECT 'France',                 924317,              527797,            2208000,                  396520  UNION ALL
    SELECT 'Germany',               1071460,              611295,            2265600,                  460165  UNION ALL
    SELECT 'Australia',             2532003,             1474958,            2150400,                 1057045
) p
GROUP BY continente
ORDER BY beneficio_bruto_total DESC;
