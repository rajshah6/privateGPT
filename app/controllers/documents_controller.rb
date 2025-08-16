class DocumentsController < ApplicationController
  # Skip CSRF token verification for API requests
  protect_from_forgery with: :null_session
  
  # GET /documents
  # Returns JSON list of all stored documents
  def index
    begin
      documents = Document.all.order(created_at: :desc)
      
      # Return documents with minimal information (excluding embeddings for performance)
      render json: {
        documents: documents.map do |doc|
          {
            id: doc.id,
            content: doc.content.truncate(200), # Truncate content for overview
            created_at: doc.created_at.iso8601,
            updated_at: doc.updated_at.iso8601,
            has_embedding: doc.embedding.present?
          }
        end,
        total_count: documents.count,
        timestamp: Time.current.iso8601
      }, status: :ok
      
    rescue => e
      Rails.logger.error "Documents index error: #{e.message}"
      
      render json: {
        error: "Internal server error",
        message: "Could not retrieve documents"
      }, status: :internal_server_error
    end
  end

  # POST /documents
  # Accepts JSON: { content: "Document content here" }
  # Returns JSON: { document: {...} }
  def create
    # Validate that content parameter is present
    unless params[:content].present?
      render json: {
        error: "Content parameter is required",
        message: "Please provide a 'content' parameter with the document text"
      }, status: :bad_request
      return
    end
    
    begin
      # Create document with content
      document = Document.new(content: params[:content].strip)
      
      if document.save
        # Generate embedding for the document
        begin
          document.generate_embedding!
          
          render json: {
            document: {
              id: document.id,
              content: document.content,
              created_at: document.created_at.iso8601,
              updated_at: document.updated_at.iso8601,
              has_embedding: document.embedding.present?
            },
            message: "Document created and embedded successfully",
            timestamp: Time.current.iso8601
          }, status: :created
          
        rescue EmbeddingService::EmbeddingError => e
          # Document was saved but embedding failed
          Rails.logger.error "Embedding generation failed: #{e.message}"
          
          render json: {
            document: {
              id: document.id,
              content: document.content,
              created_at: document.created_at.iso8601,
              updated_at: document.updated_at.iso8601,
              has_embedding: false
            },
            warning: "Document saved but embedding generation failed",
            message: "You may need to regenerate embeddings later"
          }, status: :created
        end
      else
        render json: {
          error: "Document validation failed",
          errors: document.errors.full_messages
        }, status: :unprocessable_entity
      end
      
    rescue => e
      Rails.logger.error "Document creation error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      render json: {
        error: "Internal server error",
        message: "Could not create document"
      }, status: :internal_server_error
    end
  end
  
  private
  
  # Strong parameters for document requests
  def document_params
    params.permit(:content)
  end
end
