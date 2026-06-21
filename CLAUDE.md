# Mostrador — CRM de proveedores para una cafetería

Contexto para trabajar en este proyecto. Leé esto antes de hacer cambios.

## Qué es
App web para que una cafetería organice sus proveedores: fichas de contacto,
comparación de precios entre proveedores, historial de aumentos, registro de
compras y carga automática de datos con IA (pegando una conversación o subiendo
un catálogo/PDF). El usuario no es desarrollador; valora la simplicidad.

## Arquitectura (importante)
- **Frontend**: un único archivo `index.html` (HTML + CSS + JavaScript vanilla, sin
  framework y SIN paso de build). Todo el estado y el render están ahí.
- **Datos**: Supabase (Postgres). El navegador habla directo con Supabase usando
  `@supabase/supabase-js` (cargado por CDN). Las credenciales van en las
  constantes `SUPABASE_URL` y `SUPABASE_ANON_KEY` arriba del `index.html`.
- **IA**: una Supabase Edge Function en `supabase/functions/extraer-proveedor/index.ts`
  (Deno/TypeScript) que guarda la API key de Anthropic como secreto del lado del
  servidor y llama a la API de Anthropic para extraer los datos del proveedor.
  El navegador NUNCA ve la API key de Anthropic.
- **Hosting**: el código va en GitHub y se publica con GitHub Pages. NO se usa Vercel.

Decisión deliberada: se descartó Vercel + Neon para no agregar una capa de
funciones de servidor en el frontend. Todo es "GitHub + Supabase y nada más".
La única función de servidor es la Edge Function de Supabase (solo para la IA).

## Mapa de archivos
- `index.html` — la app completa (UI + lógica + estilos).
- `schema.sql` — crea las tablas y políticas en Supabase (se corre una vez en el SQL Editor).
- `supabase/functions/extraer-proveedor/index.ts` — Edge Function para la carga con IA.
- `README.md` — puesta en marcha paso a paso para el usuario.
- `CLAUDE.md` — este archivo.

## Modelo de datos (3 tablas)
- `proveedores`: id, nombre, categoria, contacto, telefono, email, direccion,
  antelacion_dias (int), condiciones_pago, notas, creado.
- `precios`: id, proveedor_id (FK, on delete cascade), producto, unidad, precio
  (numeric), fecha, creado. El historial de aumentos se calcula comparando
  precios del mismo proveedor+producto ordenados por fecha.
- `compras`: id, proveedor_id (FK, on delete set null), fecha, total, detalle, notas, creado.

## Convenciones del frontend
- Capa de datos: `initData`, `fetchAll`, `insertRow/updateRow/deleteRow`. Hay un
  **modo demo** (`isDemo`): si faltan las credenciales de Supabase, carga datos
  de ejemplo en memoria (`loadDemoData`) y no persiste nada. Mantener ese modo
  funcionando al hacer cambios.
- Vistas: `viewPanel`, `viewProveedores`, `viewPrecios`, `viewCompras`,
  `viewAjustes`. El router es el listener de `#nav` que llama a `render()`.
- Todo texto que venga de datos se escapa con `esc()`. Lo que va dentro de
  `onclick` con strings dinámicos se pasa con `encodeURIComponent` + `decodeURIComponent`.
- Precios en pesos argentinos, formateados con `fmtARS`. Fechas `dd/mm/aaaa` con `fmtFecha`.

## Lenguaje visual (respetar)
Inspirado en una referencia concreta: estilo claro y aireado.
- Tipografía: **Inter Tight** (títulos, compacta, bold) + **Inter** (cuerpo).
- Fondo gris claro `--bg`, tarjetas casi blancas muy redondeadas (`--radius:20px`).
- Header tipo "hero" con el nombre + "👋" y navegación con **badges circulares negros**.
- Firma visual: cada tarjeta de proveedor tiene un **blob con degradé** según su
  categoría (mapa `CAT_GRAD` → `catGrad()`). El "mejor precio" usa un degradé cálido amarillo.
- Acentos monocromáticos (negro) + los degradés de categoría como único color fuerte.
- Tokens de color/espaciado en `:root`. Reusarlos; no hardcodear colores nuevos sin necesidad.

## Cómo correr / desplegar
- Frontend: abrir `index.html` en el navegador (arranca en modo demo).
- Base: crear proyecto en Supabase, correr `schema.sql`, pegar URL + anon key en `index.html`.
- IA: `supabase secrets set ANTHROPIC_API_KEY=...` y `supabase functions deploy extraer-proveedor`.
- Publicar: push a GitHub → GitHub Pages (Settings → Pages → rama `main`).

## Seguridad / cuidados
- La `anon key` de Supabase viaja en el cliente (es normal), protegida por las
  políticas RLS del `schema.sql`. Hoy esas políticas permiten leer/escribir a
  cualquiera con la key. Si se endurece, considerar Supabase Auth (login).
- La API key de Anthropic SOLO vive como secreto en la Edge Function. Nunca en el cliente.
- El modelo de Anthropic usado en la función es `claude-sonnet-4-6` (cambiable).

## Pendientes / ideas para crecer
- Login con usuarios y roles (Supabase Auth).
- Alertas de reposición según `antelacion_dias` y última compra.
- Exportar a Excel/CSV para el contador.
- Múltiples sucursales (columna `sucursal`).
- Ajustar la paleta de degradés a la marca real de la cafetería.

## Estilo de trabajo esperado
Mantener todo en un solo `index.html` salvo que haya buena razón para separar.
Cambios chicos y verificables. Preservar el modo demo y el lenguaje visual.
