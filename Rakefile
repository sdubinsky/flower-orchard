require 'rake/testtask'
namespace :db do
  db_address = ENV["DATABASE_URL"] || "postgres://localhost/machikoro"
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
