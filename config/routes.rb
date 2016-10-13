Rails.application.routes.draw do
  root to: "catalog#index"
  # we define the root route in initializers/high_voltage.rb
  # root to: "catalog#index"

  mount Blacklight::Engine => '/'

  devise_for :users

  concern :searchable, Blacklight::Routes::Searchable.new
  concern :exportable, Blacklight::Routes::Exportable.new

  resource :catalog, only: [:index], controller: 'catalog' do
    concerns :searchable
  end

  resources :solr_documents, only: [:show], controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end


  # OLD ADL routes
  get '/catalog/:id/facsimile' => 'catalog#facsimile', as: 'facsimile_catalog'
  get 'oai' => 'catalog#oai'
  get '/catalog/:id/feedback' => 'catalog#feedback', as: 'feedback_catalog'
  get '/authors' => 'catalog#authors'
  get '/periods' => 'catalog#periods'
  get '/allworks/:authorid' => 'catalog#allworks'
end
