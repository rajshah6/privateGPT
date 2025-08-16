# SunLife AI Chatbot

A Ruby on Rails API application that implements an AI chatbot with Retrieval-Augmented Generation (RAG) using PostgreSQL with pgvector extension, OpenAI embeddings, and a local LlamaCpp server.

## Features

- **Document Storage with Vector Embeddings**: Store documents with embeddings using PostgreSQL and pgvector
- **Semantic Search**: Find relevant documents using cosine similarity
- **RAG (Retrieval-Augmented Generation)**: Combine retrieved context with AI generation
- **Local LLM Integration**: Works with locally running LlamaCpp server
- **RESTful API**: Clean JSON API for chat and document management

## System Requirements

- Ruby 3.2+
- PostgreSQL 14+ with pgvector extension
- OpenAI API key for embeddings
- Local LlamaCpp server running on port 8000

## Setup Instructions

### 1. Install Dependencies

```bash
bundle install
```

### 2. Database Setup

Install PostgreSQL and the pgvector extension:

```bash
# Install pgvector extension in your PostgreSQL instance
# For Homebrew on macOS:
brew install pgvector

# Connect to PostgreSQL and create extension:
psql -d your_database -c "CREATE EXTENSION vector;"
```

Create and configure your database:

```bash
# Update config/database.yml with your PostgreSQL credentials
# Then create the database
bin/rails db:create
bin/rails db:migrate
```

### 3. Environment Variables

Create a `.env` file or set environment variables:

```bash
export OPENAI_API_KEY="your-openai-api-key"
export LLAMA_CPP_URL="http://localhost:8000/completion"  # Optional, defaults to localhost:8000
export DATABASE_USERNAME="postgres"  # Optional
export DATABASE_PASSWORD="your-password"  # Optional
export DATABASE_HOST="localhost"  # Optional
```

### 4. Start LlamaCpp Server

Download and run a local LlamaCpp server:

```bash
# Example with llama.cpp
./server -m your-model.gguf -c 2048 --port 8000
```

The server should accept POST requests at `/completion` with JSON payload:

```json
{
  "prompt": "Your prompt here",
  "max_tokens": 500,
  "temperature": 0.7
}
```

### 5. Start the Rails Server

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
  -d '{"content": "Artificial intelligence (AI) is a branch of computer science that deals with creating intelligent machines."}'
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
  -d '{"query": "What is artificial intelligence?"}'
```

### 4. API Documentation

Visit the root endpoint for interactive API documentation:

```bash
curl http://localhost:3000/
```

## Project Structure

```
app/
├── controllers/
│   ├── application_controller.rb      # Base controller with API info
│   ├── chat_controller.rb            # Chat endpoint
│   └── documents_controller.rb       # Document management
├── models/
│   └── document.rb                   # Document model with vector support
└── services/
    ├── embedding_service.rb          # OpenAI embedding generation
    └── chat_service.rb              # RAG chat processing
config/
├── initializers/
│   └── sunlife_ai.rb                # App configuration
└── routes.rb                        # API routes
db/
└── migrate/
    └── create_documents.rb           # Document table with vector field
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

## Configuration

### Embedding Model

- Default: `text-embedding-3-small` (1536 dimensions)
- Configurable in `app/services/embedding_service.rb`

### LlamaCpp Integration

- Default URL: `http://localhost:8000/completion`
- Configurable via `LLAMA_CPP_URL` environment variable
- Expected response format: `{"content": "response text"}` or `{"choices": [{"text": "response"}]}`

### Vector Search

- Uses cosine similarity for document retrieval
- Returns top 5 most relevant documents by default
- Configurable in `app/services/chat_service.rb`

## Troubleshooting

### pgvector Issues

- Ensure pgvector extension is installed in PostgreSQL
- Check that the migration created the vector column correctly
- Verify the index was created for similarity search

### Embedding Generation Fails

- Verify your OpenAI API key is correct
- Check internet connectivity for API calls
- Review logs for specific error messages

### LlamaCpp Connection Issues

- Ensure your LlamaCpp server is running on the correct port
- Test the server directly with curl
- Check the server accepts the expected JSON format

### No Relevant Documents Found

- Upload documents to the knowledge base first
- Ensure documents have been embedded successfully
- Try different query formulations

## Development

### Running Tests

```bash
bin/rails test
```

### Console Access

```bash
bin/rails console

# Example usage:
Document.create!(content: "Ruby is a programming language")
ChatService.ask("What is Ruby?")
```

### Adding New Models

The embedding model can be changed in `EmbeddingService`:

```ruby
EMBEDDING_MODEL = "text-embedding-3-large"  # More accurate but larger
EMBEDDING_DIMENSION = 3072  # Update dimension accordingly
```

Remember to update the migration and reindex existing documents when changing embedding dimensions.

## License

This project is available under the MIT License.

- Deployment instructions

- ...
