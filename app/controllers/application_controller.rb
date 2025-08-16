class ApplicationController < ActionController::API
  # API information endpoint
  def api_info
    render json: {
      name: "SunLife AI Chatbot API",
      version: "1.0.0",
      description: "AI-powered chatbot with Retrieval-Augmented Generation (RAG)",
      endpoints: {
        chat: {
          method: "POST",
          path: "/chat",
          description: "Ask a question to the AI chatbot",
          parameters: {
            query: "The question to ask (required)"
          },
          example: {
            request: { query: "What is artificial intelligence?" },
            response: { 
              answer: "Artificial intelligence (AI) refers to...",
              query: "What is artificial intelligence?",
              timestamp: "2025-08-16T21:56:05Z"
            }
          }
        },
        documents: {
          create: {
            method: "POST",
            path: "/documents",
            description: "Upload a document for the knowledge base",
            parameters: {
              content: "The document content (required)"
            },
            example: {
              request: { content: "AI is a branch of computer science..." },
              response: {
                document: {
                  id: 1,
                  content: "AI is a branch of computer science...",
                  created_at: "2025-08-16T21:56:05Z",
                  has_embedding: true
                }
              }
            }
          },
          index: {
            method: "GET",
            path: "/documents",
            description: "List all documents in the knowledge base",
            example: {
              response: {
                documents: [
                  {
                    id: 1,
                    content: "AI is a branch of...",
                    created_at: "2025-08-16T21:56:05Z",
                    has_embedding: true
                  }
                ],
                total_count: 1
              }
            }
          }
        }
      },
      timestamp: Time.current.iso8601
    }
  end
end
