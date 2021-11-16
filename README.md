To connect a database with any CGMr app, all you need is this package.

This package is also intended for interactive work, such as setting up or modifying the database, in case you don't want to deal with SQL.

Initialize a database object

``` r
db <- cgm_db()
db$con  # return the connection, for use in other functions
db$list_objects() # show all the objects in this database
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
