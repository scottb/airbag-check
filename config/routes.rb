Rails.application.routes.draw do
  namespace :api do
    get 'airbag/:state/:plate', to: 'airbag#show', constraints: { state: /^[[:alpha:]]{2}$/ }
  end
end
