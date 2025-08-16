namespace :embeddings do
  desc "Generate embeddings for all documents without embeddings"
  task generate_missing: :environment do
    puts "Finding documents without embeddings..."
    
    documents_without_embeddings = Document.where(embedding: nil)
    total_count = documents_without_embeddings.count
    
    if total_count == 0
      puts "All documents already have embeddings!"
      next
    end
    
    puts "Found #{total_count} documents without embeddings"
    puts "Generating embeddings..."
    
    success_count = 0
    error_count = 0
    
    documents_without_embeddings.find_each.with_index do |document, index|
      begin
        print "Processing document #{index + 1}/#{total_count}... "
        document.generate_embedding!
        success_count += 1
        puts "✓"
      rescue => e
        error_count += 1
        puts "✗ (#{e.message})"
      end
    end
    
    puts "\nCompleted!"
    puts "Success: #{success_count}"
    puts "Errors: #{error_count}"
  end
  
  desc "Regenerate all embeddings (use with caution)"
  task regenerate_all: :environment do
    puts "WARNING: This will regenerate embeddings for ALL documents"
    print "Are you sure? (y/N): "
    
    response = STDIN.gets.chomp.downcase
    unless response == 'y' || response == 'yes'
      puts "Cancelled."
      next
    end
    
    total_count = Document.count
    puts "Regenerating embeddings for #{total_count} documents..."
    
    success_count = 0
    error_count = 0
    
    Document.find_each.with_index do |document, index|
      begin
        print "Processing document #{index + 1}/#{total_count}... "
        document.update!(embedding: nil)  # Clear existing embedding
        document.generate_embedding!
        success_count += 1
        puts "✓"
      rescue => e
        error_count += 1
        puts "✗ (#{e.message})"
      end
    end
    
    puts "\nCompleted!"
    puts "Success: #{success_count}"
    puts "Errors: #{error_count}"
  end
  
  desc "Test embedding generation with sample text"
  task test: :environment do
    sample_text = "This is a test document for embedding generation."
    
    puts "Testing embedding generation..."
    puts "Sample text: #{sample_text}"
    
    begin
      embedding = EmbeddingService.embed_text(sample_text)
      
      if embedding.present?
        puts "✓ Embedding generated successfully!"
        puts "Embedding dimension: #{embedding.length}"
        puts "First 5 values: #{embedding.first(5)}"
      else
        puts "✗ Embedding generation returned nil"
      end
    rescue => e
      puts "✗ Error generating embedding: #{e.message}"
    end
  end
  
  desc "Show embedding statistics"
  task stats: :environment do
    total_documents = Document.count
    documents_with_embeddings = Document.where.not(embedding: nil).count
    documents_without_embeddings = total_documents - documents_with_embeddings
    
    puts "Embedding Statistics:"
    puts "===================="
    puts "Total documents: #{total_documents}"
    puts "With embeddings: #{documents_with_embeddings}"
    puts "Without embeddings: #{documents_without_embeddings}"
    
    if total_documents > 0
      percentage = (documents_with_embeddings.to_f / total_documents * 100).round(2)
      puts "Coverage: #{percentage}%"
    end
    
    if documents_with_embeddings > 0
      puts "\nSample embedding info:"
      sample_doc = Document.where.not(embedding: nil).first
      puts "Sample document ID: #{sample_doc.id}"
      puts "Embedding dimension: #{sample_doc.embedding.length}"
    end
  end
end
