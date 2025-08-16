class Document < ApplicationRecord
  # Validations
  validates :content, presence: true
  
  # Scope for nearest neighbor search using cosine similarity
  scope :nearest_neighbors, ->(query_embedding, limit: 5) {
    select("*, embedding <=> '#{query_embedding}' AS distance")
      .order("embedding <=> '#{query_embedding}'")
      .limit(limit)
  }
  
  # Alternative scope using pgvector's cosine distance operator
  scope :similar_to, ->(query_embedding, limit: 5) {
    where("embedding IS NOT NULL")
      .order(Arel.sql("embedding <=> '#{query_embedding}'"))
      .limit(limit)
  }
  
  # Instance method to generate and save embedding
  def generate_embedding!
    return unless content.present?
    
    embedding_vector = EmbeddingService.embed_text(content)
    update!(embedding: embedding_vector)
  end
  
  # Check if document has an embedding
  def has_embedding?
    embedding.present?
  end
  
  # Calculate similarity to another embedding
  def similarity_to(other_embedding)
    return 0.0 unless has_embedding? && other_embedding.present?
    
    EmbeddingService.cosine_similarity(embedding, other_embedding)
  end
end
