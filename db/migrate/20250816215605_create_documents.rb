class CreateDocuments < ActiveRecord::Migration[8.0]
  def change
    # Enable pgvector extension
    enable_extension "vector"
    
    create_table :documents do |t|
      t.text :content
      t.vector :embedding, limit: 1536  # OpenAI text-embedding-3-small dimension

      t.timestamps
    end
    
    # Add index for vector similarity search
    add_index :documents, :embedding, using: :ivfflat, opclass: :vector_cosine_ops
  end
end
