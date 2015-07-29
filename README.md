# Getting Started
## First time only
```bash
bundle install
rake db:migrate 
rake jetty:clean
rake adl:config # load our solr config
rake jetty:start
rake adl:seed # populate disc with a sample doc
```
## Every time
```bash
rake jetty:start
rails s
```
