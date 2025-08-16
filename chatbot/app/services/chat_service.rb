# Service for handling chat requests with RAG (Retrieval-Augmented Generation)
class ChatService
  # Configuration for local LlamaCpp server
  LLAMA_CPP_URL = ENV['LLAMA_CPP_URL'] || 'http://localhost:8000/completion'
  DEFAULT_CONTEXT_LIMIT = 5
  
  class << self
    # Main method to process a chat query using RAG
    # @param query [String] The user's question
    # @param context_limit [Integer] Number of documents to retrieve for context
    # @return [String] The generated response from the AI
    def ask(query, context_limit: DEFAULT_CONTEXT_LIMIT)
      return "Please provide a question." if query.blank?
      
      begin
        # Step 1: Generate embedding for the user query
        query_embedding = EmbeddingService.embed_text(query)
        
        if query_embedding.blank?
          return "Sorry, I couldn't process your question. Please try again."
        end
        
        # Step 2: Retrieve relevant documents using vector similarity
        relevant_docs = retrieve_relevant_documents(query_embedding, context_limit)
        
        # Step 3: Build context from retrieved documents
        context = build_context_from_documents(relevant_docs)
        
        # Step 4: Generate response using local LlamaCpp server
        response = generate_response_with_context(query, context)
        
        response
      rescue => e
        Rails.logger.error "Chat service error: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        "Sorry, I encountered an error while processing your question. Please try again."
      end
    end
    
    private
    
    # Retrieve documents most similar to the query embedding
    # @param query_embedding [Array<Float>] The query's embedding vector
    # @param limit [Integer] Number of documents to retrieve
    # @return [ActiveRecord::Relation] Collection of relevant documents
    def retrieve_relevant_documents(query_embedding, limit)
      # Convert embedding array to PostgreSQL vector format
      vector_string = "[#{query_embedding.join(',')}]"
      Document.similar_to(vector_string, limit)
    end
    
    # Build a context string from retrieved documents
    # @param documents [ActiveRecord::Relation] Retrieved documents
    # @return [String] Formatted context string
    def build_context_from_documents(documents)
      return "No relevant information found." if documents.empty?
      
      context_parts = documents.map.with_index do |doc, index|
        "Document #{index + 1}:\n#{doc.content.strip}"
      end
      
      context_parts.join("\n\n")
    end
    
    # Generate response using local LlamaCpp server with context
    # @param query [String] The user's question
    # @param context [String] Retrieved context information
    # @return [String] Generated response
    def generate_response_with_context(query, context)
      # Build the prompt with context and query
      prompt = build_prompt_with_context(query, context)
      
      # Prepare payload for LlamaCpp server
      payload = {
        prompt: prompt,
        max_tokens: 500,
        temperature: 0.7,
        top_p: 0.9,
        stop: ["\n\n", "Human:", "Assistant:"]
      }
      
      # Make request to LlamaCpp server
      response = make_llama_cpp_request(payload)
      
      # Extract and clean the response
      extract_response_text(response)
    end
    
    # Build a structured prompt with context and query
    # @param query [String] The user's question
    # @param context [String] Retrieved context information
    # @return [String] Formatted prompt
    def build_prompt_with_context(query, context)
      <<~PROMPT
        Answer the following question using only the provided context. If the context doesn't contain enough information to answer the question, say so clearly.

        Context:
        #{context}

        Question: #{query}

        Answer:
      PROMPT
    end
    
    # Make HTTP request to LlamaCpp server
    # @param payload [Hash] Request payload
    # @return [Hash] Parsed response
    def make_llama_cpp_request(payload)
      conn = Faraday.new do |f|
        f.request :json
        f.response :json
        f.adapter Faraday.default_adapter
      end
      
      response = conn.post(LLAMA_CPP_URL) do |req|
        req.headers['Content-Type'] = 'application/json'
        req.body = payload
      end
      
      unless response.success?
        raise LlamaCppError, "LlamaCpp server returned #{response.status}: #{response.body}"
      end
      
      response.body
    rescue Faraday::Error => e
      raise LlamaCppError, "Failed to connect to LlamaCpp server: #{e.message}"
    end
    
    # Extract response text from LlamaCpp response
    # @param response [Hash] Response from LlamaCpp server
    # @return [String] Cleaned response text
    def extract_response_text(response)
      # LlamaCpp typically returns response in 'content' or 'choices' field
      text = response.dig('content') || 
             response.dig('choices', 0, 'text') ||
             response.dig('response') ||
             "Sorry, I couldn't generate a response."
      
      # Clean up the response text
      text.strip.gsub(/\A\s*Answer:\s*/i, '')
    end
  end
  
  # Custom error class for LlamaCpp server issues
  class LlamaCppError < StandardError; end
end
