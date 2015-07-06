# Getting Started

```bash
bundle install
rake db:migrate 
rake jetty:clean
rake adl:config # load our solr config
rake jetty:start
rake adl:seed # populate disc with a sample doc
```
