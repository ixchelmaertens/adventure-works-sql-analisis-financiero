# 📊 Análisis del Desempeño Financiero de Adventure Works con SQL

## 🧩 Contexto del negocio
Como analista en AdventureWorks, el director financiero necesitaba saber en qué mercados se generan más ingresos y rentabilidad para decidir dónde invertir el próximo presupuesto de marketing.

## 🎯 Preguntas de negocio
- ¿Qué continentes ofrecen la mejor oportunidad de inversión?
- ¿Cuánto estamos ganando por país?
- ¿Qué tan rentable es cada mercado considerando los gastos de marketing?
- ¿Qué productos son los más rentables?
- ¿Existen territorios donde el gasto de marketing parece ineficiente?

## 🛠️ Herramientas utilizadas
- SQL (replicable en [SQLiteOnline](https://sqliteonline.com))
- Google Sheets (Resumen ejecutivo CFI)
- IBM Cognos (Dashboard y visualizaciones)

## 📂 Dataset
Subconjunto del dataset público **AdventureWorks** con las tablas:
`ventas_2017` · `productos` · `productos_categorias` · `clientes` · `territorios` · `campanas`

## 🔍 Proceso de análisis
1. **Exploración del esquema** — Diagrama de entidades e identificación de claves de unión
2. **Extracción y limpieza** — JOINs, manejo de NULLs, columnas calculadas (`ingreso_total`, `costo_total`)
3. **Cálculo de KPIs financieros** — Beneficio Bruto, Margen % y ROI %
4. **Validación y QA** — Verificación de totales, detección de anomalías y revisión de nulos
5. **Informe ejecutivo** — Formato Contexto → Hallazgo → Implicación

## 📈 KPIs calculados
| Métrica | Descripción |
|---|---|
| Ingreso Total | Precio unitario × Cantidad pedida |
| Costo Total | Costo unitario × Cantidad pedida |
| Beneficio Bruto | Ingreso Total − Costo Total |
| Margen % | Beneficio Bruto / Ingreso Total |
| ROI % | Beneficio Bruto / Gasto en Marketing |

## 💡 Hallazgos principales
- **Oportunidad por Continente:** Norteamérica es la mejor opción   de inversión general (43.61% margen, 47.34% ROI); si la inversión   va estrictamente a pauta publicitaria, Oceanía lidera con 49.16% ROI.
- **País líder:** United States lidera tanto en ingresos totales como en ROI de campañas de marketing.
- **Rentabilidad real:** Solo Australia y United States generan ingresos superiores al costo de sus campañas — los únicos mercados con ROMI positivo real.
- **Gasto ineficiente:** Francia (17.96% ROI) y Canadá (17.43% ROI) son los territorios menos eficientes. Canadá gastó $1.82M en marketing para ingresar solo $710K; Francia gastó $2.2M para ingresar $924K.
- **Rentabilidad por categoría:** Accesorios lidera en margen porcentual (62.75%), impulsado por productos como Sport-100 Helmet (64.25% de margen, $21.62 de ganancia unitaria).
 
## 🚨 Implicaciones para el negocio
1. Priorizar inversión general en **Norteamérica**; redirigir presupuesto de marketing específicamente hacia **Oceanía** por su mayor ROI publicitario.
2. El gasto de marketing es **insostenible** en todos los mercados excepto Australia y Estados Unidos — compromete la utilidad global a pesar del margen bruto aparente.
3. **Optimizar o reasignar** el presupuesto de Francia y Canadá hacia mercados con ROI comprobado; replantear campañas publicitarias en ambos países de forma urgente.
4. **Incentivar venta por volumen** en Accesorios por su alto margen porcentual e **impulsar comercialmente** Mountain-200 Silver y Bicicletas por su beneficio bruto absoluto más alto del catálogo.

## 📁 Archivos del repositorio
- `queries.sql` — Consultas del análisis del bootcamp
- `queries_analisis_extendido.sql` — Consultas adicionales desarrolladas por iniciativa propia
- `Proyecto 3_...SS Google Sheets.png` — Resumen ejecutivo CFI en Google Sheets
- `01_dashboard_general.png` — Vista ejecutiva con KPIs principales (IBM Cognos)
- `02_ingresos_vs_costos_por_pais.png` — Comparativo por país (IBM Cognos)
- `03_roi_marketing_por_continente.png` — ROI por continente (IBM Cognos)
- `04_rentabilidad_unitaria_producto.png` — Rentabilidad por producto (IBM Cognos)
- `05_margen_ganancia_por_producto.png` — Margen por producto (IBM Cognos)
