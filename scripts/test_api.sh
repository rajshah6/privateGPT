#!/bin/bash

# Test script for SunLife AI Chatbot API
# Make sure the Rails server is running before executing this script

BASE_URL="http://localhost:3000"

echo "🧪 Testing SunLife AI Chatbot API"
echo "================================="

# Test 1: Check API info
echo "1. Testing API info endpoint..."
curl -s -X GET "$BASE_URL/" | jq '.' || echo "Failed to get API info"
echo -e "\n"

# Test 2: Upload a test document
echo "2. Testing document upload..."
curl -s -X POST "$BASE_URL/documents" \
  -H "Content-Type: application/json" \
  -d '{"content": "Ruby on Rails is a web application framework written in Ruby. It follows the Model-View-Controller (MVC) pattern and emphasizes convention over configuration."}' | jq '.' || echo "Failed to upload document"
echo -e "\n"

# Test 3: List documents
echo "3. Testing document listing..."
curl -s -X GET "$BASE_URL/documents" | jq '.' || echo "Failed to list documents"
echo -e "\n"

# Test 4: Upload another document
echo "4. Uploading another test document..."
curl -s -X POST "$BASE_URL/documents" \
  -H "Content-Type: application/json" \
  -d '{"content": "PostgreSQL is a powerful, open-source object-relational database system. It supports advanced data types and performance optimization features."}' | jq '.' || echo "Failed to upload second document"
echo -e "\n"

# Test 5: Test chat endpoint (this will likely fail without proper setup)
echo "5. Testing chat endpoint..."
curl -s -X POST "$BASE_URL/chat" \
  -H "Content-Type: application/json" \
  -d '{"query": "What is Ruby on Rails?"}' | jq '.' || echo "Chat test failed (expected if LlamaCpp/OpenAI not configured)"
echo -e "\n"

echo "✅ API testing completed!"
echo ""
echo "Notes:"
echo "- If chat fails, make sure OPENAI_API_KEY is set and LlamaCpp server is running"
echo "- Documents need embeddings to work with chat (run: rails embeddings:generate_missing)"
echo "- Install jq for better JSON formatting: brew install jq"
