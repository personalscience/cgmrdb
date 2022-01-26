To connect a database with any CGMr app, all you need is this package.

This package is also intended for interactive work, such as setting up or modifying the database, in case you don't want to deal with SQL.

Initialize a database object

``` r
db <- cgm_db(db_config = "sqldb")
db$con  # return the connection, for use in other functions
db$list_objects() # show all the objects in this database
```

## Tables

This package probably should be implemented entirely in SQL. In fact, you should be able to create a new database from the `qsdb.sql` source. Originally the intent was to make something that could work across any kind of database using the `DBI::` package high level functions.

Here are the key tables that the rest of the Taster package depends on

### Users and Accounts

-   `user_list` : (legacy) list of users and their `user_id`. Intended only for users whose data is not associated with a Firebase account. Usually this means people whose CGM data was entered without them having an account.

-   `accounts_user` All user accounts. Contains their permission levels.

-   `accounts_firebase` Mapping of Firebase IDs to `user_id`.

-   `accounts_user_demographics`: Maps `user_id` to basic demographics, like age or geography.

New accounts can only be created with Firebase. When searching for the `user_id` of a person who new logs in, the system first tries to match the Firebase ID with what exists in `accounts_firebase`. If there is no match, a new unique `user_id` is created and added to `accounts_firebase`.

### Data

-   `glucose_records`: canonical dataframe of glucose values

-   `glucose_raw`: raw data in its original Libreview format

-   `notes_records`: time series metadata, filtered into a canonical form for better performance.

-   `notes_raw`: time series metadata, in the raw form in which it was acquired.

## Examples

Create a new Postgres database following the connection details in `config.yml`. If no such database exists, it will be created. Otherwise the various tables are left alone. Then return the number of unique `user_id` in the `glucose_records` table.

``` r
sandbox_db <- cgm_db(db_config = "sandbox")
sandbox_db$glucose_records %>% distinct(user_id)
sql_db <- cgm_db(db_config = "sqldb")  # Or make a SQLite version. 
```

### Using `tasterdb` Package

After a database has been created this way, you can fill it with Tastermonial data using the `tasterdb` package. This will wipe any tables created previously and write them with new data from the Tastermonial data directory configured by `config.yml`.

``` r
taster_db <- tasterdb::load_db(ps_database = "sandbox")
```

In this example, read the notes files as raw data, then convert them to appropriate formats.

Write a brand new table based on the dataframe `raw_notes`. Because it's a hard-wired raw notes function, it will give the table an index `Comment`.

``` r
raw_notes <- tasterdb::run_taster_notes(raw = TRUE) %>% 
  bind_rows(cgmr::notes_df_from_glucose_table(local_db$glucose_records, user_id = 1234) %>% 
  filter(Start>"2021-06-01"))
new_notes <- raw_notes %>%
  mutate(Comment = map_chr(stringr::str_to_upper(Comment), tasterdb::taster_classify_food))
  
write_notes_raw_from_scratch(sandbox_db$con, raw_notes)
```

## Configuration

This package expects a `config.yml` file, either in the working directory, or in a parent. Be sure to fill in all the values below correctly:

``` yaml
default:
  dataconnection:
    driver: !expr RPostgres::Postgres()
    host: "localhost"
    user: "postgres"
    password: 'yourlocalpassword'
    port: 5432
    dbname: 'qsdb'
    glucose_table: 'glucose_records'

sqldb:
  dataconnection:
    driver: !expr RSQLite::SQLite()
    dbname: "mydb.sqlite"
    user: ""
    password: ""
    port: NULL
    host: "localhost"
    glucose_table: "glucose_records"

remote:
  dataconnection:
    driver: !expr RPostgres::Postgres()
    host: "<IP address for local host>"
    user: "username"
    password: 'password'
    port: 5432
    dbname: 'qsdb'
    glucose_table: 'glucose_records'
```

To use the local database, run

``` r
Sys.setenv(R_CONFIG_ACTIVE = "local")  # which maps to the default connection
```

The default values on all my databases assume the user is `postgres`, so keep that in mind if you ever start a Postgres database instance from scratch, or upgrade from a previous version.

## Back Up and Save

You can give any name to your database, though by convention I use `qsdb`. The Postgres command line utilities are handy for backing up and restoring an existing database.

Save the schema

``` zsh
pg_dump qsdb --schema-only -U postgres > qsdb.sql
```

To see just the tables

``` bash
pg_dump -s qsdb -U postgres | awk 'RS="";/CREATE TABLE[^;]*;/'
```

Here's how I saved the entire contents of `qsdb` to a tar file

``` bash
pg_dump -U postgres -F t qsdb > qsdb.tar
```

Read that tar file into a new database `qsdb2` like this:

``` sqlpostgresql
(base) ➜  cgmrdb git:(dev) ✗ psql -U postgres
psql (14.1)
Type "help" for help.

postgres=> create database qsdb2 ;
CREATE DATABASE
postgres=> \q
(base) ➜  cgmrdb git:(dev) ✗ pg_restore --host localhost --port 5432  --dbname "qsdb2"  qsdb.tar
(base) ➜  cgmrdb git:(dev) ✗
```

## 
