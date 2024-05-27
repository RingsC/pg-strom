---
--- initialization of regression test database
---
SELECT current_database();
\gset

\getenv regress_dataset_revision REGRESS_DATASET_REVISION
SELECT pgstrom.regression_testdb_revision() = cast(:regress_dataset_revision as text) revision_check_result
\gset

\if :revision_check_result
---
--- OK, regression test database is the latest revision
---
SELECT pgstrom.regression_testdb_revision();

\else
BEGIN;
---
--- special GUC configuration
---
ALTER DATABASE :current_database SET pg_strom.regression_test_mode = on;

---
--- add initial data loading here
---


\set revision_checker_body 'SELECT CAST(':regress_dataset_revision' as text)'

CREATE OR REPLACE FUNCTION
pgstrom.regression_testdb_revision()
RETURNS text
AS :'revision_checker_body'
LANGUAGE 'sql';

COMMIT;
--- revision confirmation
SELECT pgstrom.regression_testdb_revision();

\endif
