-- Lengkapi profil untuk akun yang terlanjur dibuat tanpa baris profiles.
-- Tanpa baris ini, insert ke plans/workouts/daily_metrics/user_settings gagal
-- karena foreign key ke profiles.id.
insert into public.profiles (id, email, full_name, avatar_initial, role)
select
  u.id,
  coalesce(u.email, ''),
  coalesce(
    u.raw_user_meta_data ->> 'full_name',
    split_part(coalesce(u.email, ''), '@', 1)
  ),
  upper(left(coalesce(u.raw_user_meta_data ->> 'full_name', u.email, 'S'), 1)),
  'user'
from auth.users u
left join public.profiles p on p.id = u.id
where p.id is null;

-- Pastikan akun baru tetap otomatis mendapat profil.
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();
