create table if not exists salary_type (
    id serial primary key,
    description varchar(9) not null
);

create table if not exists contract_type (
    id serial primary key,
    description varchar(10) not null 
);

create table if not exists location (
    id serial primary key,
    description text not null unique
);

create table if not exists employer (
    id serial primary key,
    name text not null unique,
    industry text
);

create table if not exists skill (
    id serial primary key,
    name text not null,
    area text not null
);

create table if not exists job (
    hash char(41) not null primary key,
    id integer not null,
    title text not null,
    description text not null,
    min_salary numeric(8, 2),
    max_salary numeric(8, 2),
    date date not null,
    expiration_date date,
    external_url text,
    url text not null,
    employer_id integer references employer(id),
    location_id integer references location(id),
    salary_type_id integer references salary_type(id),
    contract_type_id integer references contract_type(id)
);

create table if not exists job_skill_bridge (
    job_id integer references job(hash),
    skill_id integer references skill(id)
);