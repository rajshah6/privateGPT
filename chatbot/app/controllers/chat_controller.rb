class ChatController < ApplicationController
  # Skip CSRF token verification for API requests
  protect_from_forgery with: :null_session
  
  # POST /chat
  # Accepts JSON: { query: "Your question here" }
  # Returns JSON: { answer: "AI response" }
  def create
    # Validate that query parameter is present
    unless params[:query].present?
      render json: { 
        error: "Query parameter is required",
        message: "Please provide a 'query' parameter with your question"
      }, status: :bad_request
      return
    end
    
    begin
      # Process the query through ChatService
      query = params[:query].strip
      answer = ChatService.ask(query)
      
      # Return successful response
      render json: { 
        answer: answer,
        query: query,
        timestamp: Time.current.iso8601
      }, status: :ok
      
    rescue => e
      Rails.logger.error "Chat controller error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      # Return error response
      render json: { 
        error: "Internal server error",
        message: "Sorry, something went wrong while processing your request"
      }, status: :internal_server_error
    end
  end
  
  private
  
  # Strong parameters for chat requests
  def chat_params
    params.permit(:query)
  end
end
