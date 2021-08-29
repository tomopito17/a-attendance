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
      # ユーザー情報変更フォーム
      patch 'update_index'

      #勤怠変更
      get 'attendances/edit_one_month'  #11.1.1
      patch 'attendances/update_one_month'  #11.1.5add

      #A06 1ヶ月承認
      get 'attendances/monthly_confirmation_form'  #edit_month_approval
      patch 'attendances/update_month_approval'

      #A05 「勤怠を確認する」ページ
      get 'verification'
    end

    resources :attendances, only: [:update] do # この行を追加します。#A03
      collection do #A04
        get 'overwork_confirmation_form'
        patch 'update_overwork_confirmation_form'
        #get 'monthly_confirmation_form'
        #patch 'update_monthly_confirmation_form'
      end
      member do #A03残業申請  #A061ヶ月勤怠変更
        get 'overwork_form' #A03残業申請
        patch 'update_overwork' #A03残業申請更新
        #A06 勤怠編集と通知モーダル
        get 'edit_one_month_notice'
        patch 'update_one_month_notice'
        #A06 1ヶ月承認モーダル　1ヶ月勤怠変更
        get 'monthly_confirmation_form'
        patch 'update_month_approval_notice'
        # 勤怠ログ
        get 'log'
      end
    end
  end

   #拠点情報
  resources :working_places#A02追加0509
end

#A04上長画面一ヶ月分勤怠申請のお知らせフォーム
  # get  '/monthly_confirmation_form',    to: 'attendances#monthly_confirmation_form'
  # post  '/monthly_confirmation_form',    to: 'attendances#monthly_confirmation_form'

  #A04一ヶ月分の申請
  #patch  '/monthly_confirmation',    to: 'attendances#monthly_confirmation'


