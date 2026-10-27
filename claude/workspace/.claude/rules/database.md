---
paths:
  - "**/migrations/**"
  - "**/migrate/**"
  - "**/db/migrate/**"
  - "**/alembic/**"
  - "**/alembic/versions/**"
  - "**/models/**"
  - "**/models.py"
  - "**/serializers.py"
  - "**/querysets.py"
---

# Database Rules

## Migration Safety (all environments)

- **Never modify an existing migration.**
  Always create a new migration for changes.
  Existing migrations may have already run in production.
- Every migration must be reversible.
  Implement both `forwards` / `backwards` (Django) or `up()` / `down()` (Laravel) equivalents.
- **Migrations must never be skipped.**
  Run the migration command in full; never `--fake` outside of explicit documented recovery procedures.
- Never drop columns or tables without first confirming the data is no longer needed and a deprecation period has passed.
- Never seed production data in migration files. Use dedicated fixture or seed files.
- Add indexes in their own migration, never bundled with schema changes.
- Test migrations in both directions before committing.

## Query Discipline: N+1 is a bug

Apply the section that matches the project's ORM.
The same principles hold for any other ORM.

### Django ORM

- Always use `select_related()` for forward ForeignKey/OneToOne traversals.
- Always use `prefetch_related()` for reverse relations and ManyToMany.
- Never access a related field inside a loop without prefetching.
- Use `only()` or `defer()` when you do not need all fields of a fat model.
- Annotate with `Count`, `Sum`, `Avg` via `aggregate()` or `annotate()`; never iterate in Python.
- Use `bulk_create()` and `bulk_update()` for batch writes. Never call `.save()` inside a loop.
- Wrap multi-step writes in `transaction.atomic()`. Never leave partial writes unprotected.
- Use `select_for_update()` when reads must lock rows for subsequent writes.
- Never use raw SQL unless the ORM cannot express the query.
  If unavoidable, use `cursor.execute()` with parameterized placeholders; never f-strings or `.format()`.

### Laravel Eloquent

- Always call `->with()` to eager-load relationships before iterating over a collection.
- Never access a relationship property inside a `foreach` without eager loading.
- Use `->withCount()` when you only need a count, not full related records.
- Use `DB::transaction(function () { ... })` to wrap multi-step writes.
- Use `->chunkById()` for large dataset iteration. Never `->all()` on unbounded tables.
- Parameterize all raw queries via `DB::select()` with bindings. Never interpolate user input.

## Schema Conventions

- All new models must include `created_at` / `updated_at` (for example `auto_now_add` / `auto_now` in Django).
- Use `UUIDField` as the primary key for externally exposed models to prevent enumeration.
- Never store sensitive personal or regulated data in plaintext without confirming field-level encryption is in place.
- Use the framework's migrations for all schema changes. Never alter tables manually.
- Never use `ENUM` columns; use `tinyint` with application-level constants or a lookup table.
