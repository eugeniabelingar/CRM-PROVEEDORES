-- ============================================================
-- Mostrador · CRM de proveedores
-- Pegá TODO este archivo en el SQL Editor de Supabase y ejecutalo.
-- ============================================================

create table proveedores (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  categoria text not null default 'Otros',
  contacto text,
  telefono text,
  email text,
  direccion text,
  antelacion_dias int not null default 0,
  condiciones_pago text,
  notas text,
  creado timestamptz not null default now()
);

create table precios (
  id uuid primary key default gen_random_uuid(),
  proveedor_id uuid not null references proveedores(id) on delete cascade,
  producto text not null,
  unidad text not null default 'unidad',
  precio numeric not null check (precio >= 0),
  fecha date not null default current_date,
  creado timestamptz not null default now()
);

create table compras (
  id uuid primary key default gen_random_uuid(),
  proveedor_id uuid references proveedores(id) on delete set null,
  fecha date not null default current_date,
  total numeric not null default 0 check (total >= 0),
  detalle text,
  notas text,
  creado timestamptz not null default now()
);

-- Índices útiles para cuando crezca el volumen de datos
create index precios_proveedor_idx on precios (proveedor_id);
create index precios_producto_idx on precios (lower(producto));
create index compras_fecha_idx on compras (fecha desc);

-- ============================================================
-- Seguridad (Row Level Security)
-- Estas políticas permiten leer y escribir a cualquiera que tenga
-- la clave "anon" (es decir: vos y tus socios usando la app).
-- Importante: no compartas la URL de tu app públicamente.
-- Más adelante se puede agregar login con usuarios de Supabase.
-- ============================================================

alter table proveedores enable row level security;
alter table precios enable row level security;
alter table compras enable row level security;

create policy "acceso total proveedores" on proveedores
  for all using (true) with check (true);

create policy "acceso total precios" on precios
  for all using (true) with check (true);

create policy "acceso total compras" on compras
  for all using (true) with check (true);
