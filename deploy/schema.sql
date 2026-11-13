create extension if not exists pgcrypto;
create table if not exists public.btv_admins(user_id uuid primary key references auth.users(id) on delete cascade,created_at timestamptz default now());
create table if not exists public.btv_contents(id uuid primary key default gen_random_uuid(),title text not null,description text not null default '',kind text not null default 'video' check(kind in ('video','episode','live')),category text not null default 'Notícias',program text,season integer,episode integer,video_url text,thumbnail_url text,status text not null default 'draft' check(status in ('draft','published')),featured boolean not null default false,sort_order integer not null default 0,created_at timestamptz not null default now(),updated_at timestamptz not null default now(),constraint published_has_video check(status<>'published' or nullif(trim(video_url),'') is not null));
create or replace function public.btv_is_admin() returns boolean language sql stable security definer set search_path='' as $$ select exists(select 1 from public.btv_admins where user_id=auth.uid()) $$;
revoke all on function public.btv_is_admin() from public; grant execute on function public.btv_is_admin() to authenticated;
alter table public.btv_admins enable row level security;alter table public.btv_contents enable row level security;
create policy "btv_admin_acesso" on public.btv_admins for select to authenticated using(user_id=auth.uid());
create policy "btv_leitura" on public.btv_contents for select to anon,authenticated using(status='published' or (select public.btv_is_admin()));
create policy "btv_criar" on public.btv_contents for insert to authenticated with check((select public.btv_is_admin()));
create policy "btv_editar" on public.btv_contents for update to authenticated using((select public.btv_is_admin())) with check((select public.btv_is_admin()));
create policy "btv_eliminar" on public.btv_contents for delete to authenticated using((select public.btv_is_admin()));
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types) values('btv-images','btv-images',true,8388608,array['image/jpeg','image/png','image/webp']),('btv-videos','btv-videos',true,104857600,null) on conflict(id) do nothing;
create policy "btv_imagens_publicas" on storage.objects for select to anon,authenticated using(bucket_id='btv-images');
create policy "btv_videos_publicos" on storage.objects for select to anon,authenticated using(bucket_id='btv-videos');
create policy "btv_carregar" on storage.objects for insert to authenticated with check(bucket_id in ('btv-images','btv-videos') and (select public.btv_is_admin()) and (storage.foldername(name))[1]=auth.uid()::text);
-- Criar utilizador em Authentication e autorizar:
-- insert into public.btv_admins(user_id) values ('UUID-DO-ADMIN');