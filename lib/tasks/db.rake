namespace :db do
  desc "Clear all tables"
  task :clear => :environment do
    conn = ActiveRecord::Base.connection
    conn.tables.select{|t| t.start_with? ActiveRecord::Base.table_name_prefix }.each do |t|
      conn.drop_table t
    end
  end
  
  desc "Dump database into an SQL file"
  task :dump => :environment do
    datestamp = Time.now.strftime("%Y-%m-%d_%H-%M-%S")
    backup_folder = File.join(Rails.root, ENV["DIR"] || "db", 'backup')
    backup_file = File.join(backup_folder, "development_#{datestamp}_dump.sql.gz")
    Dir.mkdir(backup_folder) unless File.directory? backup_folder
    db_config = ActiveRecord::Base.configurations["development"]
    tables = ActiveRecord::Base.connection.tables.select{|table| table.start_with? ActiveRecord::Base.table_name_prefix }
    host_or_socket = db_config.has_key?('host') ? "-h #{db_config['host']}" : "-S #{db_config['socket']}"
    sh "mysqldump #{host_or_socket} -u #{db_config['username']} #{'-p' if db_config['password']}#{db_config['password']} --opt #{db_config['database']} #{tables.join ' '} | gzip -c > #{backup_file}"
  end
  
  desc "Load from SQL file to the database"
  task :load => :environment do
    db_config = ActiveRecord::Base.configurations[Rails.env]
    file = (ENV["FILE"]) ? File.join(Rails.root, ENV["FILE"]) : Dir[File.join(Rails.root, 'db', 'backup', "#{Rails.env}**.sql*")].first
    host_or_socket = db_config.has_key?('host') ? "-h #{db_config['host']}" : "-S #{db_config['socket']}"
    raise "Please specify FILE." unless file
    command = ''
    command << "gunzip -c #{file} | " if file.end_with? '.gz'
    command << "mysql #{host_or_socket} -u #{db_config['username']} #{'-p' if db_config['password']}#{db_config['password']} #{db_config['database']}"
    command << " < #{file}" unless file.end_with? '.gz'
    sh command
  end
end