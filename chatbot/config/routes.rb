Rails.application.routes.draw do
  # API routes for the AI chatbot
  
  # Chat endpoint
  post "chat", to: "chat#create"
  
  # Document management endpoints
  resources :documents, only: [:index, :create]
  
  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check
  
  # API documentation endpoint (optional)
  get "api", to: "application#api_info"
  
  # Root path for API info
  root to: "application#api_info"
end
