# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :admin do
    resources :users, only: %i[index update edit]
    resources :brokerages, only: %i[index new create edit update]
  end

  root 'listings#index'
  get '/agent/:id', to: 'agent_listings#index', as: 'agent_listings'
  resources :listings do
    resources :pictures, only: %i[destroy]
    resources :open_houses, only: %i[new create edit update destroy]
    resources :inquiries, only: %i[new create]
  end
  resources :favorites, only: %i[index create destroy]
  resources :mailer_subscriptions, only: %i[edit update]
  resources :inquiries, only: :index
  resources :saved_searches, only: %i[index create update destroy]

  devise_for :users

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
