To connect a database with any CGMr app, all you need is this package.

This package is also intended for interactive work, such as setting up or modifying the database, in case you don't want to deal with SQL.

Initialize a database object

``` r
db <- cgm_db(db_config = "sqldb")
db$con  # return the connection, for use in other functions
db$list_objects() # show all the objects in this database
```

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

