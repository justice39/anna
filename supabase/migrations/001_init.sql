-- Anna v1 schema
-- Run this in your Supabase SQL editor on a fresh project.

create extension if not exists "uuid-ossp";

create table reminders (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references auth.users not null,
  title text not null,
  notes text,
  scheduled_at timestamptz not null,
  recurrence text not null default 'none', -- 'none', 'daily', 'weekdays', 'weekly'
  alert_type text not null default 'alert', -- 'alert' or 'call'
  is_active boolean not null default true,
  is_critical boolean not null default false,
  ringtone text not null default 'bell_chime',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index reminders_user_scheduled on reminders(user_id, scheduled_at)
  where is_active = true;

-- Auto-update updated_at
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger reminders_updated_at
  before update on reminders
  for each row
  execute function set_updated_at();

-- Row level security
alter table reminders enable row level security;

create policy "Users see own reminders"
  on reminders for select
  using (auth.uid() = user_id);

create policy "Users insert own reminders"
  on reminders for insert
  with check (auth.uid() = user_id);

create policy "Users update own reminders"
  on reminders for update
  using (auth.uid() = user_id);

create policy "Users delete own reminders"
  on reminders for delete
  using (auth.uid() = user_id);

-- Enable realtime
alter publication supabase_realtime add table reminders;
