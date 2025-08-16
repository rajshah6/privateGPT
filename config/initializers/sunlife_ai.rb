# Configuration for SunLife AI Chatbot
Rails.application.configure do
  # Ensure pgvector is loaded when using PostgreSQL
  config.active_record.schema_format = :sql if config.active_record.adapter_name == 'PostgreSQL'
  
  # Configure CORS for API access (uncomment and customize as needed)
  # config.middleware.insert_before 0, Rack::Cors do
  #   allow do
  #     origins '*' # Configure this to specific domains in production
  #     resource '*',
  #       headers: :any,
  #       methods: [:get, :post, :put, :patch, :delete, :options, :head],
  #       credentials: false
  #   end
  # end
end

# Environment variable validation
required_env_vars = %w[OPENAI_API_KEY]
missing_vars = required_env_vars.select { |var| ENV[var].blank? }

if missing_vars.any? && Rails.env.production?
  Rails.logger.warn "Missing required environment variables: #{missing_vars.join(', ')}"
  Rails.logger.warn "Some features may not work correctly without these variables."
end

# LlamaCpp server configuration validation
llama_cpp_url = ENV['LLAMA_CPP_URL'] || 'http://localhost:8000/completion'
Rails.logger.info "LlamaCpp server configured at: #{llama_cpp_url}"

# Log embedding service configuration
if ENV['OPENAI_API_KEY'].present?
  Rails.logger.info "OpenAI API key configured for embedding generation"
else
  Rails.logger.warn "OpenAI API key not found. Set OPENAI_API_KEY environment variable."
end
