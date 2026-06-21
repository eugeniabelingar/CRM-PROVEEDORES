# Mostrador · CRM de proveedores para tu cafetería ☕

App web para organizar proveedores, comparar precios, ver historial de aumentos y registrar compras. Pensada para usarse entre socios, gratis y en línea.

**Qué incluye:**
- **Panel**: indicadores generales, últimos aumentos de precio, proveedores por categoría, compras recientes y antelación de pedidos.
- **Proveedores**: fichas con contacto, dirección, condiciones de pago, antelación de pedidos y notas, con búsqueda y filtro por categoría.
- **Precios**: comparador entre proveedores (marca el mejor precio) e historial con porcentaje de variación y gráfico de evolución.
- **Compras**: registro histórico de pedidos con totales.

La app funciona en **modo demo** (con datos de ejemplo) hasta que la conectes a Supabase. Eso te permite probarla ya mismo abriendo `index.html` en el navegador.

---

## Puesta en marcha (una sola vez, ~30 minutos)

### Paso 1 — Crear la base de datos en Supabase

1. Entrá a [supabase.com](https://supabase.com) y creá una cuenta gratuita (podés usar tu cuenta de GitHub).
2. Tocá **New project**. Elegí un nombre (ej: `crm-cafeteria`), una contraseña para la base (guardala) y la región **South America (São Paulo)** para que sea rápida desde Argentina.
3. Cuando el proyecto termine de crearse, andá al menú lateral → **SQL Editor**.
4. Abrí el archivo `schema.sql` de este proyecto, copiá **todo** su contenido, pegalo en el editor y tocá **Run**. Eso crea las tres tablas (proveedores, precios y compras) con sus permisos.
5. Andá a **Settings → API** y dejá a mano dos datos:
   - **Project URL** (algo como `https://abcdefgh.supabase.co`)
   - **anon public key** (una clave larga que empieza con `eyJ...`)

### Paso 2 — Conectar la app

1. Abrí `index.html` con cualquier editor de texto.
2. Cerca del principio vas a ver la sección **CONFIGURACIÓN**:

```js
const SUPABASE_URL = "";        // ej: "https://abcdefgh.supabase.co"
const SUPABASE_ANON_KEY = "";   // la clave "anon public"
```

3. Pegá tus dos valores entre las comillas y guardá el archivo.
4. Abrí `index.html` en el navegador: la barra lateral tiene que decir **"Supabase conectado"**. Probá cargar un proveedor y recargar la página: si sigue ahí, quedó funcionando.

### Paso 3 — Subir el código a GitHub

1. Creá un repositorio nuevo en [github.com](https://github.com) (puede ser **privado**; recomendado, porque el archivo contiene tu clave anon).
2. Subí los archivos del proyecto (`index.html`, `schema.sql`, `README.md`). Podés hacerlo desde la web con **Add file → Upload files**, o por terminal:

```bash
git init
git add .
git commit -m "CRM de proveedores"
git branch -M main
git remote add origin https://github.com/TU_USUARIO/TU_REPO.git
git push -u origin main
```

### Paso 4 — Publicarla en la web con GitHub Pages

1. En tu repositorio de GitHub, andá a **Settings → Pages**.
2. En *Source*, elegí la rama **`main`** y la carpeta **`/ (root)`**. Guardá.
3. Esperá un minuto y GitHub te va a dar una URL tipo `https://tu-usuario.github.io/tu-repo`. Esa es la dirección que compartís con tus socios.

Cada vez que subas un cambio al repo, GitHub Pages republica la nueva versión automáticamente.

> **Importante sobre repos públicos:** GitHub Pages gratuito requiere que el repositorio sea **público**, y el `index.html` lleva tu clave anon de Supabase a la vista. Esa clave está pensada para vivir en el navegador y la base está protegida por las políticas del `schema.sql`, pero como esas políticas hoy permiten leer y escribir a cualquiera que tenga la clave, alguien que encuentre tu repo podría modificar los datos. Para arrancar y probar entre socios alcanza. Cuando quieras cerrarlo, mirá la sección "Seguridad" más abajo.

---

## Paso 5 (opcional) — Activar la carga automática con IA

Esto habilita el botón **"Leer conversación o catálogo"** dentro de *Nuevo proveedor*: pegás una charla de WhatsApp o subís un PDF/foto del catálogo y la app completa sola los datos del proveedor y los precios.

Necesita una pieza más: una **función de Supabase** que guarda en secreto tu clave de la API de Anthropic (así nunca queda expuesta en el código público). Se despliega una sola vez.

> **Costo:** esta función usa la API de Anthropic, que se paga **por uso** y es independiente de tu suscripción de Claude.ai. Cada extracción cuesta centavos de dólar. Si no la activás, la app funciona igual; solo no aparece la lectura automática.

1. **Conseguí una API key de Anthropic.** Entrá a [console.anthropic.com](https://console.anthropic.com), creá una cuenta, cargá un crédito mínimo y generá una key (empieza con `sk-ant-...`).

2. **Instalá la CLI de Supabase.** En tu compu:
   ```bash
   npm install -g supabase
   ```

3. **Vinculá tu proyecto** (el `project-ref` lo ves en la URL de tu panel de Supabase, o en Settings → General):
   ```bash
   supabase login
   supabase link --project-ref TU_PROJECT_REF
   ```

4. **Guardá la clave como secreto** (no va en el código):
   ```bash
   supabase secrets set ANTHROPIC_API_KEY=sk-ant-tu-clave-aca
   ```

5. **Desplegá la función** (la carpeta `supabase/functions/extraer-proveedor` ya está en este proyecto):
   ```bash
   supabase functions deploy extraer-proveedor
   ```

Listo. Volvé a la app, entrá a *Nuevo proveedor → Leer conversación o catálogo*, pegá algo y probá. Si algo falla, lo más común es que falte el secreto (paso 4) o el deploy (paso 5).



- **Usá siempre el mismo nombre de producto** al cargar precios ("Leche entera" siempre igual). El formulario te sugiere los nombres ya usados. Así la app puede comparar proveedores y calcular los aumentos.
- Cuando un proveedor te pasa una lista nueva, no edites el precio viejo: **cargá un precio nuevo con la fecha de hoy**. El historial de aumentos sale de ahí.
- La **antelación de pedidos** de cada proveedor aparece ordenada en el panel: úsala para planificar la semana.

## Seguridad: lo que tenés que saber

- Cualquier persona que tenga la **URL de la app** puede ver y modificar los datos (la clave `anon` viaja en la página). Para 2-3 socios alcanza con no compartir el link ni el repositorio.
- Cuando quieras cerrarlo, tenés dos caminos sin cambiar de arquitectura:
  - **Login de Supabase**: que cada socio entre con usuario y contraseña. Supabase trae el login integrado (Supabase Auth) y se suma a esta misma app sin tocar la base de datos.
  - **Repositorio privado**: GitHub Pages gratis pide repo público, pero podés mantener el repo **privado** y publicar la página igual de gratis con [Netlify](https://www.netlify.com) (acepta repos privados sin costo). Así tu clave deja de estar a la vista.

## Ideas para cuando te expandas

Todas se pueden sumar sobre esta misma base:
- Login con usuarios y roles (quién puede borrar, quién solo cargar).
- Alertas de reposición ("hace 25 días que no comprás café y el proveedor pide 7 de antelación").
- Exportar a Excel/CSV para tu contador.
- Múltiples sucursales (una columna `sucursal` en compras).
