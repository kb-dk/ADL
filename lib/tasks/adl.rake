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
    doc_path = Rails.root.join('solr_conf', 'doc.xml')
    open doc_path do |f|
      doc = f.read
      solr = RSolr.connect(url: 'http://localhost:8983/solr/blacklight-core/')
      solr.update(data: doc)
      solr.commit
    end
  end
end