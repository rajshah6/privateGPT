# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Sample documents for development and testing
sample_documents = [
  {
    content: "Artificial Intelligence (AI) is a branch of computer science that aims to create intelligent machines that can perform tasks that typically require human intelligence. These tasks include learning, reasoning, problem-solving, perception, and language understanding."
  },
  {
    content: "Machine Learning is a subset of artificial intelligence that provides systems the ability to automatically learn and improve from experience without being explicitly programmed. It focuses on the development of computer programs that can access data and use it to learn for themselves."
  },
  {
    content: "Deep Learning is a subset of machine learning that uses neural networks with three or more layers. These neural networks attempt to simulate the behavior of the human brain, allowing it to 'learn' from large amounts of data."
  },
  {
    content: "Natural Language Processing (NLP) is a subfield of linguistics, computer science, and artificial intelligence concerned with the interactions between computers and human language, in particular how to program computers to process and analyze large amounts of natural language data."
  },
  {
    content: "Computer Vision is an interdisciplinary scientific field that deals with how computers can gain high-level understanding from digital images or videos. From the perspective of engineering, it seeks to understand and automate tasks that the human visual system can do."
  },
  {
    content: "Retrieval-Augmented Generation (RAG) is a technique that combines information retrieval with text generation. It first retrieves relevant documents from a knowledge base and then uses that information to generate more accurate and contextually relevant responses."
  },
  {
    content: "Ruby on Rails is a server-side web application framework written in Ruby. It is a model-view-controller (MVC) framework, providing default structures for a database, a web service, and web pages. Rails emphasizes convention over configuration and the DRY (Don't Repeat Yourself) principle."
  },
  {
    content: "PostgreSQL is a powerful, open-source object-relational database system with over 30 years of active development. It has a strong reputation for reliability, feature robustness, and performance. It supports both SQL and JSON querying."
  },
  {
    content: "Vector databases are specialized databases designed to store and query high-dimensional vectors efficiently. They are commonly used in machine learning applications for similarity search, recommendation systems, and semantic search capabilities."
  },
  {
    content: "Large Language Models (LLMs) are artificial intelligence systems trained on vast amounts of text data to understand and generate human-like text. Examples include GPT-4, Claude, and LLaMA, which can perform various language tasks such as translation, summarization, and question answering."
  }
]

puts "Creating sample documents..."

sample_documents.each_with_index do |doc_data, index|
  # Use find_or_create_by to avoid duplicates
  document = Document.find_or_create_by(content: doc_data[:content]) do |doc|
    puts "Creating document #{index + 1}: #{doc_data[:content].truncate(50)}"
  end
  
  # Generate embedding if it doesn't exist and if OpenAI API key is available
  if document.embedding.blank? && ENV['OPENAI_API_KEY'].present?
    begin
      puts "Generating embedding for document #{document.id}..."
      document.generate_embedding!
      puts "✓ Embedding generated"
    rescue => e
      puts "✗ Failed to generate embedding: #{e.message}"
    end
  elsif document.embedding.present?
    puts "Document #{document.id} already has embedding"
  else
    puts "Skipping embedding generation (no OpenAI API key)"
  end
end

puts "\nSeed data creation completed!"
puts "Total documents: #{Document.count}"
puts "Documents with embeddings: #{Document.where.not(embedding: nil).count}"

if ENV['OPENAI_API_KEY'].blank?
  puts "\nNote: Set OPENAI_API_KEY environment variable and run 'rails embeddings:generate_missing' to generate embeddings."
end
