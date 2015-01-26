module Embulk
  require 'jdbc/postgres'
  Jdbc::Postgres.load_driver

  class OutputPostgresJson < OutputPlugin
    Plugin.register_output('postgres_json', self)

    def self.transaction(config, schema, processor_count, &control)
      task = {
        'host' => config.param('host', :string),
        'port' => config.param('port', :string, default: 5432),
        'username' => config.param('username', :string),
        'password' => config.param('password', :string, default: ''),
        'database' => config.param('database', :string),
        'table' => config.param('table', :string),
        'column' => config.param('column', :string, default: 'json'),
        'column_type' => config.param('column_type', :string, default: 'json'),
      }

      now = Time.now
      unique_name = "%08x%08x" % [now.tv_sec, now.tv_nsec]  # TODO add org.embulk.spi.ExecSession.getTransactionUniqueName() method
      task['temp_table'] = "#{task['table']}_LOAD_TEMP_#{unique_name}"

      connect(task) do |pg|
        # drop table if exists "DEST"
        # create table if exists "TEMP" ("COL" json)
        execute_sql(pg, %[drop table if exists "#{task['temp_table']}"])
        execute_sql(pg, %[create table "#{task['temp_table']}" ("#{task['column']}" #{task['column_type']})])
      end

      begin
        yield(task)

        connect(task) do |pg|
          # create table if not exists "DEST" ("COL" json)
          # insert into "DEST" ("COL") select "COL" from "TEMP"
          execute_sql(pg, %[create table if not exists "#{task['table']}" ("#{task['column']}" #{task['column_type']})])
          execute_sql(pg, %[insert into "#{task['table']}" ("#{task['column']}") select "#{task['column']}" from "#{task['temp_table']}"])
        end

      ensure
        connect(task) do |pg|
          # drop table if exists TEMP
          execute_sql(pg, %[drop table if exists "#{task['temp_table']}"])
        end
      end

      return {}
    end

    def self.connect(task)
      url = "jdbc:postgresql://#{task['host']}:#{task['port']}/#{task['database']}"
      props = java.util.Properties.new
      props.put("user", task['username'])
      props.put("password", task['password'])

      pg = org.postgresql.Driver.new.connect(url, props)
      if block_given?
        begin
          yield pg
        ensure
          pg.close
        end
      end
      pg
    end

    def self.execute_sql(pg, sql, *args)
      stmt = pg.createStatement
      begin
        stmt.execute(sql)
      ensure
        stmt.close
      end
    end

    def initialize(task, schema, index)
      super
      @pg = self.class.connect(task)
    end

    def close
      @pg.close
    end

    def add(page)
      prep = @pg.prepareStatement(%[insert into "#{@task['temp_table']}" (#{@task['column']}) values (?::json)])
      begin
        page.each do |record|
          prep.setString(1, record.to_json)
          prep.execute
        end
      ensure
        prep.close
      end
    end

    def finish
    end

    def abort
    end

    def commit
      {}
    end
  end

end
