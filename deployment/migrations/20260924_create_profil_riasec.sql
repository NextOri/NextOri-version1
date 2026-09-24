-- NextOri - Profils RIASEC partagés
--
-- Migration additive et réexécutable pour Supabase PostgreSQL.
-- Elle ne modifie aucune table métier existante et ne contient aucune suppression.
-- Les données des 30 profils seront ajoutées dans une migration dédiée, après
-- validation du contenu rédactionnel.

begin;

create table if not exists public.profil_riasec (
    code varchar(2) primary key,
    nom varchar(100) not null,
    description text not null,
    forces jsonb not null default '[]'::jsonb,
    competences jsonb not null default '[]'::jsonb,
    environnements jsonb not null default '[]'::jsonb,
    actif boolean not null default true,
    date_creation timestamptz not null default now(),
    date_modification timestamptz not null default now(),
    constraint profil_riasec_code_format check (
        code ~ '^[RIASEC]{2}$'
        and substring(code from 1 for 1) <> substring(code from 2 for 1)
    ),
    constraint profil_riasec_forces_array check (jsonb_typeof(forces) = 'array'),
    constraint profil_riasec_competences_array check (jsonb_typeof(competences) = 'array'),
    constraint profil_riasec_environnements_array check (jsonb_typeof(environnements) = 'array')
);

comment on table public.profil_riasec is
    'Référentiel partagé des descriptions et informations des profils RIASEC à deux lettres.';

alter table public.profil_riasec enable row level security;

drop policy if exists "Lecture publique des profils RIASEC" on public.profil_riasec;
create policy "Lecture publique des profils RIASEC"
    on public.profil_riasec
    for select
    using (actif = true);

commit;
