**Folders**

`src/`: backend falcon source code


to run locally, first have redis running locally on port 6379, then use `./dev_run_server.sh`



alembic (Postgres Schema Migration Tool)

to create schema migration:
`alembic revision --autogenerate -m'Test'` in alembic/dev or alembic/prod
this only creates the schema to be applied. does not actually apply it
take a look at the code to be run to apply schema. should be in output. usually in alembic/versions/ directory

to apply latest schema:
`alembic upgrade head` in alembic/dev or alembic/prod
BE CAREFUL PROD IS LINKED TO ACTUAL PROD DB you must have the prod creds in ~/.marble/config.prod

