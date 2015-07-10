namespace :adl do
  desc 'Load ADL Solr Config'
  task :config do
    solr_conf_dir = Rails.root.join('jetty', 'solr', 'blacklight-core', 'conf')
    schema = Rails.root.join('solr_conf', 'schema.xml')
    solr_conf = Rails.root.join('solr_conf', 'solrconfig.xml')
    stopwords = Rails.root.join('solr_conf', 'stopwords_da.txt')
    FileUtils.cp schema, solr_conf_dir
    FileUtils.cp solr_conf, solr_conf_dir
    FileUtils.cp stopwords, solr_conf_dir
  end

  task seed: :environment do
    data_path = Rails.root.join('solr_conf', 'seed_data')
    data_path.each_child do |e|
      next if e.directory?
      begin
        open e do |f|
          puts "ingesting #{f.path}"
          doc = f.read
          solr = RSolr.connect(url: Blacklight.connection_config[:url])
          solr.update(data: doc)
          solr.commit
        end
      rescue Exception => e
        puts "error loading solerdoc #{doc}: #{e.message}"
      end
    end
  end

  task :clear do
    system "curl -H 'Content-Type: text/xml' #{Blacklight.connection_config[:url]}/update?commit=true --data-binary '<delete><query>*:*</query></delete>'"
  end

end