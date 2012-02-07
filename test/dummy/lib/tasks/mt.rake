namespace 'mt:db' do

  def load_data_inner
    config = ActiveRecord::Base.configurations['test_mt']

    ActiveRecord::Base.establish_connection(config)
    connection = ActiveRecord::Base.connection
    if ENV['DUMP_FILE'].blank?
      raise 'The environment variable "DUMP_FILE" is required'
    end
    open(ENV['DUMP_FILE']).read.split(/;$/).each do |line|
      connection.execute line
    end
  end

  def load_data
    load_data_inner
  rescue
    # retry
    load_data_inner
  end

  desc "Create Movable Type Database"
  task :create => :environment do
    config = ActiveRecord::Base.configurations['test_mt']
    begin
      ActiveRecord::Base.establish_connection(config)
      ActiveRecord::Base.connection
    rescue
      case config['adapter']
      when /mysql/
        ActiveRecord::Base.establish_connection(config.merge('database' => nil))
        ActiveRecord::Base.connection.
          create_database(config['database'], config)
      end
    end
  end

  desc "Load Movable Type Data"
  task :load => :create do
    load_data
  end

  desc "Reload Movable Type Data"
  task :reload => :environment do
    load_data
  end

end
