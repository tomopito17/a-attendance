Rails.application.routes.draw do
  #6.1-get 'sessions/new'   #get 'users/new'
  root 'static_pages#top'
  get '/signup', to: 'users#new'


  # ログイン機能
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

#importCSV
  post '/import_csv', to: 'users#import_csv'  #A01
 
  resources :users do #add9.3do
    post 'import_csv'  #A01
    member do
      get 'edit_basic_info'
      patch 'update_basic_info'
      get 'attendances/edit_one_month'  #11.1.1
      patch 'attendances/update_one_month'  #11.1.5add
    end

    resources :attendances, only: :update # この行を追加します。  
  end  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  #拠点情報
  resources :working_places#追加0509


end