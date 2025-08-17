# Local AI Chatbot

A Ruby on Rails API application that implements an AI chatbot with Retrieval-Augmented Generation (RAG) using PostgreSQL with pgvector extension, OpenAI embeddings, and a local LlamaCpp server.

## Features

- **Document Storage with Vector Embeddings**: Store documents with embeddings using PostgreSQL and pgvector
- **Semantic Search**: Find relevant documents using cosine similarity
- **RAG (Retrieval-Augmented Generation)**: Combine retrieved context with AI generation
- **Local LLM Integration**: Works with locally running LlamaCpp server
- **RESTful API**: Clean JSON API for chat and document management

## Setup Instructions

### 1. Install Dependencies

```bash
bundle install
```

### 2. Environment Variables

Create a `.env` file or set environment variables:

```bash
export OPENAI_API_KEY="your-openai-api-key"
export LLAMA_CPP_URL="http://localhost:8000/completion"  # Optional, defaults to localhost:8000
export DATABASE_USERNAME="postgres"  # Optional
export DATABASE_PASSWORD="your-password"  # Optional
export DATABASE_HOST="localhost"  # Optional
```

### 3. Start LlamaCpp Server

Download and run a local LlamaCpp server:

```bash
# Example with llama.cpp
./server -m your-model.gguf -c 2048 --port 8000
```

### 4. Start the Rails Server

```bash
bin/rails server
```

The API will be available at `http://localhost:3000`

## API Usage

### 1. Upload Documents

Add documents to the knowledge base:

```bash
curl -X POST http://localhost:3000/documents \
  -H "Content-Type: application/json" \
  -d '{"content": "Let's define a new term called "glob". This refers to rocks and mountains."}'
```

### 2. List Documents

View all stored documents:

```bash
curl http://localhost:3000/documents
```

### 3. Ask Questions

Chat with the AI using uploaded documents as context:

```bash
curl -X POST http://localhost:3000/chat \
  -H "Content-Type: application/json" \
  -d '{"query": "What is a glob?"}'
```

## How It Works

1. **Document Upload**: When you upload a document, the system:

   - Saves the content to PostgreSQL
   - Generates embeddings using OpenAI's text-embedding-3-small model
   - Stores the embedding vector using pgvector

2. **Chat Query**: When you ask a question, the system:
   - Generates an embedding for your query
   - Finds the 5 most similar documents using cosine similarity
   - Builds a context string from relevant documents
   - Sends the context + query to your local LlamaCpp server
   - Returns the AI-generated response
