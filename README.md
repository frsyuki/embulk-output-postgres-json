# Embulk output plugin for PostgreSQL json column

This [Embulk](https://github.com/embulk/embulk) output plugin writes records to a json column of a table.

This works as following:

1. transaction begin: creates a temporary table
2. run: insert records to the temporary table
3. transaction commit: copy the records to the actual table and drop the temporary table

## Overview

* **Plugin type**: output
* **Load all or nothing**: yes
* **Resume supported**: no

## Configuration

- **host** host name of the PostgreSQL server (string, required)
- **port** port of the PostgreSQL server (integer, default: 5432)
- **username** login user name (string, required)
- **password** login password (string, default: "")
- **database** destination database name (string, required)
- **table** destination table name (string, required)
- **column** destination column name (string, default: "json")
- **column_type** json or jsonb (string, default: 'json')

### Example

```yaml
out:
  type: postgres_json
  host: localhost
  port: 5432
  username: pg
  database: embulk_test
  table: load01
```

