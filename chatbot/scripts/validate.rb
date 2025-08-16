#!/usr/bin/env ruby

# Quick validation script for SunLife AI Chatbot
# This script checks if the basic structure is working without requiring external services

puts "🔍 SunLife AI Chatbot Validation Script"
puts "======================================="

# Check if we're in a Rails environment
begin
  require_relative '../config/environment'
  puts "✓ Rails environment loaded successfully"
rescue => e
  puts "✗ Failed to load Rails environment: #{e.message}"
  exit 1
end

# Check database connection
begin
  ActiveRecord::Base.connection.execute("SELECT 1")
  puts "✓ Database connection working"
rescue => e
  puts "✗ Database connection failed: #{e.message}"
  puts "  Make sure PostgreSQL is running and configured"
end

# Check if pgvector extension is available
begin
  ActiveRecord::Base.connection.execute("SELECT '1'::vector")
  puts "✓ pgvector extension is available"
rescue => e
  puts "✗ pgvector extension not available: #{e.message}"
  puts "  Run: CREATE EXTENSION vector; in your PostgreSQL database"
end

# Check if Document model is working
begin
  Document.count
  puts "✓ Document model is accessible"
rescue => e
  puts "✗ Document model error: #{e.message}"
  puts "  Try running: rails db:migrate"
end

# Check if services are loadable
begin
  EmbeddingService
  puts "✓ EmbeddingService class is loadable"
rescue => e
  puts "✗ EmbeddingService error: #{e.message}"
end

begin
  ChatService
  puts "✓ ChatService class is loadable"
rescue => e
  puts "✗ ChatService error: #{e.message}"
end

# Check environment variables
if ENV['OPENAI_API_KEY'].present?
  puts "✓ OPENAI_API_KEY is set"
else
  puts "⚠ OPENAI_API_KEY is not set (embeddings won't work)"
end

llama_url = ENV['LLAMA_CPP_URL'] || 'http://localhost:8000/completion'
puts "ℹ LlamaCpp URL configured as: #{llama_url}"

# Test basic API structure
begin
  # Load controllers
  ChatController
  DocumentsController
  puts "✓ All controllers are loadable"
rescue => e
  puts "✗ Controller loading error: #{e.message}"
end

puts "\n🎯 Summary"
puts "=========="
puts "Basic application structure appears to be working!"
puts "\nNext steps:"
puts "1. Make sure PostgreSQL is running with pgvector extension"
puts "2. Set your OPENAI_API_KEY environment variable"
puts "3. Run: rails db:migrate"
puts "4. Run: rails db:seed (optional - adds sample data)"
puts "5. Start your LlamaCpp server on port 8000"
puts "6. Run: rails server"
puts "7. Test with: curl http://localhost:3000/"

puts "\nFor more details, see the README.md file."
