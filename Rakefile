require 'json'
require 'psych'
require 'rake/testtask'

namespace :db do
  if  ENV["DATABASE_URL"]
    db_address = ENV["DATABASE_URL"]
  else
    config = Psych.load_file("./config.yml")
    db_config = config['database']
    if db_config['db_username'] or db_config['db_password']
      login = "#{db_config['db_username']}:#{db_config['db_password']}@"
    else
      login = ''
    end
    db_address = "postgres://#{login}#{db_config['db_address']}/#{db_config['db_name']}"
  end
  desc "Run migrations"
  task :migrate, [:version] do |t, args|
    require "sequel/core"
    Sequel.extension :migration
    version = args[:version].to_i if args[:version]
    Sequel.connect(db_address) do |db|
      Sequel::Migrator.run(db, "db/migrations", target: version)
    end
  end
end


Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.test_files =FileList['test/test*.rb']
  t.warning = false
end
