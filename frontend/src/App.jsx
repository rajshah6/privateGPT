import { useState } from 'react'

function App() {
  const [messages, setMessages] = useState([])
  const [inputMessage, setInputMessage] = useState('')

  const sendingMessage = async (message) => {
    try {
      const response = await fetch('test', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          message: message,
          timestamp: new Date().toISOString(),
        })
      });

      const data = await response.json();
      return data;
    } catch (error) {
      console.error('Error sending message:', error);
      return null;
    }
  };

  const handleSubmit = async (val) => {
    val.preventDefault();
    if (!inputMessage.trim()) return;

    const userMsg = {
      content: inputMessage,
      sender: 'user',
      timestamp: new Date().toISOString()
    };

    setMessages(prev => [...prev, userMsg]);
    setInputMessage('');

    const response = await sendingMessage(inputMessage);

    if (response) {
      const botMsg = {
        content: response.reply,
        sender: 'bot',
        timestamp: new Date().toISOString()
      };

      setMessages(prev => [...prev, botMsg]);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-sunlife-blue to-sunlife-blue-light p-4">
      <div className="max-w-4xl mx-auto">
        {/* Header */}
        <header className="bg-white/90 backdrop-blur-sm rounded-lg shadow-lg p-4 mb-4 flex items-center gap-4 animate-slide-in">
          <img 
            src="/sunlife-logo.png" 
            alt="Sunlife Logo" 
            className="h-12 w-auto"
          />
          <div>
            <h1 className="text-2xl font-semibold text-sunlife-blue">
              SunLife Virtual Assistant
            </h1>
            <p className="text-sm text-gray-600">Your 24/7 Financial Guide</p>
          </div>
        </header>

        {/* Chat Container */}
        <div className="bg-white/90 backdrop-blur-sm rounded-lg shadow-lg flex flex-col h-[calc(100vh-180px)]">
          {/* Messages Area */}
          <div className="flex-1 overflow-y-auto p-4 space-y-4">
            {messages.length === 0 ? (
              <div className="text-center py-20 animate-fade-in">
                <div className="w-20 h-20 bg-sunlife-yellow rounded-full flex items-center justify-center mx-auto mb-6">
                  <svg 
                    className="w-12 h-12 text-white" 
                    fill="none" 
                    stroke="currentColor" 
                    viewBox="0 0 24 24"
                  >
                    <path 
                      strokeLinecap="round" 
                      strokeLinejoin="round" 
                      strokeWidth={2} 
                      d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z" 
                    />
                  </svg>
                </div>
                <h2 className="text-3xl font-bold text-sunlife-blue mb-4">
                  Welcome to SunLife Assistant! 👋
                </h2>
                <p className="text-gray-600 text-lg max-w-md mx-auto">
                  How can I help you today with your insurance and financial needs?
                </p>
              </div>
            ) : (
              messages.map((message, index) => (
                <div 
                  key={index}
                  className={`flex ${message.sender === 'user' ? 'justify-end' : 'justify-start'}`}
                >
                  <div className={`
                    max-w-[70%] rounded-2xl px-4 py-3 animate-fade-in shadow-sm
                    ${message.sender === 'user' 
                      ? 'bg-gradient-to-r from-sunlife-yellow to-sunlife-yellow-light text-sunlife-blue font-medium' 
                      : 'bg-gray-100 text-gray-800'
                    }
                  `}>
                    <p className="text-sm md:text-base">{message.content}</p>
                    <span className="text-xs opacity-70 mt-1 block">
                      {message.timestamp}
                    </span>
                  </div>
                </div>
              ))
            )}
          </div>

          {/* Input Form */}
          <form 
            onSubmit={handleSubmit}
            className="border-t border-gray-200 p-4 bg-white/50"
          >
            <div className="flex gap-3">
              <input
                type="text"
                value={inputMessage}
                onChange={(e) => setInputMessage(e.target.value)}
                placeholder="Type your message here..."
                className="flex-1 rounded-full px-6 py-3 border border-gray-300 focus:outline-none focus:border-sunlife-yellow focus:ring-2 focus:ring-sunlife-yellow/20 transition-all"
              />
              <button 
                type="submit"
                className="bg-gradient-to-r from-sunlife-yellow to-sunlife-yellow-light text-sunlife-blue p-3 rounded-full hover:shadow-lg transition-all duration-300 focus:outline-none focus:ring-2 focus:ring-sunlife-yellow/50"
              >
                <svg 
                  className="w-6 h-6" 
                  viewBox="0 0 24 24" 
                  fill="none" 
                  stroke="currentColor"
                >
                  <path 
                    d="M22 2L11 13M22 2L15 22L11 13M11 13L2 9" 
                    strokeWidth="2" 
                    strokeLinecap="round" 
                    strokeLinejoin="round"
                  />
                </svg>
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  )
}

export default App
