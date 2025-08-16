# Service for generating text embeddings using OpenAI API
class EmbeddingService
  # OpenAI embedding model configuration
  EMBEDDING_MODEL = "text-embedding-3-small".freeze
  EMBEDDING_DIMENSION = 1536
  
  class << self
    # Generate embedding for a given text using OpenAI API
    # @param text [String] The text to embed
    # @return [Array<Float>] The embedding vector
    def embed_text(text)
      return nil if text.blank?
      
      begin
        # Initialize OpenAI client through LangChain
        client = Langchain::LLM::OpenAI.new(api_key: openai_api_key)
        
        # Generate embedding
        response = client.embed(text: text, model: EMBEDDING_MODEL)
        
        # Extract embedding vector from response
        response.embedding
      rescue => e
        Rails.logger.error "Failed to generate embedding: #{e.message}"
        raise EmbeddingError, "Could not generate embedding for text"
      end
    end
    
    # Generate embeddings for multiple texts
    # @param texts [Array<String>] Array of texts to embed
    # @return [Array<Array<Float>>] Array of embedding vectors
    def embed_texts(texts)
      return [] if texts.blank?
      
      texts.map { |text| embed_text(text) }
    end
    
    # Calculate cosine similarity between two embedding vectors
    # @param embedding1 [Array<Float>] First embedding vector
    # @param embedding2 [Array<Float>] Second embedding vector
    # @return [Float] Cosine similarity score (-1 to 1)
    def cosine_similarity(embedding1, embedding2)
      return 0.0 if embedding1.blank? || embedding2.blank?
      
      dot_product = embedding1.zip(embedding2).map { |a, b| a * b }.sum
      magnitude1 = Math.sqrt(embedding1.map { |a| a * a }.sum)
      magnitude2 = Math.sqrt(embedding2.map { |a| a * a }.sum)
      
      return 0.0 if magnitude1 == 0 || magnitude2 == 0
      
      dot_product / (magnitude1 * magnitude2)
    end
    
    private
    
    # Get OpenAI API key from environment
    # @return [String] The API key
    def openai_api_key
      Rails.application.credentials.openai_api_key || ENV['OPENAI_API_KEY']
    end
  end
  
  # Custom error class for embedding failures
  class EmbeddingError < StandardError; end
end
