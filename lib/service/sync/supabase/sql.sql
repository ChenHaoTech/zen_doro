create
or replace function update_modify_at () returns trigger as $$
BEGIN
  NEW.modified_at = now();
  RETURN NEW;
END;
$$ language plpgsql;

create or replace function select_sub_tier (uuid_in uuid)
returns bigint
language sql
as $$
  select tier from public.subscription_tier
  where uuid = uuid_in
  limit 1;
$$;

# triger
create trigger update_modify_at_trigger before
update on public.notes for each row
execute function update_modify_at ();

# 删除函数
DROP FUNCTION IF EXISTS upsert_notes;

SELECT
  proname AS function_name,
  pg_proc.proargtypes AS argument_types,
  pg_type.typname AS return_type
FROM
  pg_proc
  JOIN pg_namespace ON pg_proc.pronamespace = pg_namespace.oid
  JOIN pg_type ON pg_proc.prorettype = pg_type.oid
WHERE
  pg_namespace.nspname = 'public';

-- 替换为你的模式名称，如果函数在 public 模式下
create
or replace function upsert_notes (update_appid text,uuids uuid[], new_contexts text[],new_states int[]) returns TIMESTAMPTZ as $$
DECLARE
    i INT;
    new_context TEXT;
    new_state int;
BEGIN
    FOR i IN 1..array_length(uuids, 1)
    LOOP
        new_context := new_contexts[i];
        new_state := new_states[i];
        INSERT INTO public.notes (uuid, context, user_id, modify_at,state,update_appid)
        VALUES (uuids[i], new_context, auth.uid(), now(),new_state,update_appid)
        ON CONFLICT (uuid)
        DO UPDATE SET
            context = new_context,
            state = new_state,
            update_appid = update_appid;
    END LOOP;
   RETURN now();
END;
$$ language plpgsql;

create or replace function select_unSyncNotes (mt timestamptz)
returns setof notes
language sql
as $$
  select * from notes
  where modify_at > mt AND user_id = auth.uid();
$$;


## notes policy
alter table notes enable row level security;
create policy "Individuals can create notes." on notes for
    insert with check (auth.uid() = user_id);
create policy "Individuals can view their own notes. " on notes for
    select using (auth.uid() = user_id);
create policy "Individuals can update their own notes." on notes for
    update using (auth.uid() = user_id);
create policy "Individuals can delete their own notes." on notes for
    delete using (auth.uid() = user_id);



## profile policy
alter table profile enable row level security;
create policy "Individuals can create profile." on profile for
    insert with check (auth.uid() = user_id);
create policy "Individuals can view their own profile. " on profile for
    select using (auth.uid() = user_id);
create policy "Individuals can update their own profile." on profile for
    update using (auth.uid() = user_id);
create policy "Individuals can delete their own profile." on profile for
    delete using (auth.uid() = user_id);


