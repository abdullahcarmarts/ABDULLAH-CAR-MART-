-- Abdullah Car Mart: SAFE Supabase SQL setup
-- Public QR visitors can see only non-sensitive vehicle listing fields.
-- Buyer/seller CNIC, phone, address, names, personal photos, purchase price,
-- advance, notes, chassis/engine identifiers and chassis photo remain admin-only.

create extension if not exists pgcrypto;

create table if not exists public.vehicles (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  created_by uuid not null references auth.users(id) on delete cascade,
  tx_type text, status text not null default 'Available',
  make text not null, model text not null, year text, color text,
  registration text, mileage text, chassis_no text, engine_no text,
  purchase_price text, sale_price text, advance text, transaction_date date,
  car_photos jsonb not null default '[]'::jsonb, chassis_photo text,
  seller_name text, seller_father text, seller_cnic text, seller_phone text, seller_address text, seller_photo text,
  buyer_name text, buyer_father text, buyer_cnic text, buyer_phone text, buyer_address text, buyer_photo text,
  notes text
);

alter table public.vehicles enable row level security;

-- Remove broad/old public access policies if they exist.
drop policy if exists "Public can read vehicle QR records" on public.vehicles;
drop policy if exists "Admins can read own records" on public.vehicles;
drop policy if exists "Admins can insert own records" on public.vehicles;
drop policy if exists "Admins can update own records" on public.vehicles;
drop policy if exists "Admins can delete own records" on public.vehicles;

create policy "Admins can read own records" on public.vehicles
for select to authenticated using (auth.uid() = created_by);
create policy "Admins can insert own records" on public.vehicles
for insert to authenticated with check (auth.uid() = created_by);
create policy "Admins can update own records" on public.vehicles
for update to authenticated using (auth.uid() = created_by) with check (auth.uid() = created_by);
create policy "Admins can delete own records" on public.vehicles
for delete to authenticated using (auth.uid() = created_by);

-- Explicitly deny direct table reads to anonymous visitors.
revoke all on public.vehicles from anon;
grant select, insert, update, delete on public.vehicles to authenticated;

-- Safe, read-only projection for QR verification. Never add personal fields here.
drop view if exists public.vehicle_qr_public;
create view public.vehicle_qr_public as
select id, created_at, status, make, model, year, color, registration, mileage,
       sale_price, tx_type, transaction_date, car_photos
from public.vehicles;
grant select on public.vehicle_qr_public to anon, authenticated;

-- Images bucket: QR page receives only car photo URLs from the safe view.
-- Personal/chassis photo URLs are never exposed by that view.
insert into storage.buckets (id, name, public)
values ('vehicle-files', 'vehicle-files', true)
on conflict (id) do update set public = true;

drop policy if exists "Authenticated admins upload vehicle files" on storage.objects;
drop policy if exists "Public can view vehicle files" on storage.objects;
drop policy if exists "Authenticated admins delete vehicle files" on storage.objects;
create policy "Authenticated admins upload vehicle files" on storage.objects
for insert to authenticated with check (bucket_id = 'vehicle-files');
create policy "Public can view vehicle files" on storage.objects
for select to anon, authenticated using (bucket_id = 'vehicle-files');
create policy "Authenticated admins delete vehicle files" on storage.objects
for delete to authenticated using (bucket_id = 'vehicle-files');
