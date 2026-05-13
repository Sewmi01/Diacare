# Supabase Setup For Patient Reports

This report flow now uses Supabase only:

- File storage: Supabase Storage bucket
- Report metadata: Supabase table `patient_reports`
- Firestore is no longer used for report upload/listing

## 1) .env values

```env
SUPABASE_URL='https://your-project-ref.supabase.co'
SUPABASE_ANON_KEY='your_supabase_anon_key'
SUPABASE_REPORTS_BUCKET='patient-reports'
```

## 2) Storage bucket

Create bucket `patient-reports`.

Current app expects public URLs. Use public bucket, or switch code to signed URLs later.

## 3) SQL: report table

Run in Supabase SQL editor:

```sql
create table if not exists public.patient_reports (
  id bigint generated always as identity primary key,
  patient_id text not null,
  patient_name text not null,
  title text not null default 'Doctor Report',
  image_url text not null,
  storage_provider text not null default 'supabase',
  uploaded_by_doctor_id text,
  uploaded_at timestamptz not null default now()
);

alter table public.patient_reports enable row level security;
```

## 4) SQL: RLS policies (for current anon-key app)

```sql
create policy "anon can read patient reports"
on public.patient_reports
for select
to anon
using (true);

create policy "anon can insert patient reports"
on public.patient_reports
for insert
to anon
with check (true);
```

## 5) SQL: storage policies (to fix 403 upload)

```sql
create policy "anon can upload reports to bucket"
on storage.objects
for insert
to anon
with check (bucket_id = 'patient-reports');

create policy "anon can read reports from bucket"
on storage.objects
for select
to anon
using (bucket_id = 'patient-reports');
```

## 6) Run

```bash
flutter pub get
flutter run
```
