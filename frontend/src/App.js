import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';

const API_URL = window._env_?.REACT_APP_API_URL || process.env.REACT_APP_API_URL || 'http://localhost:8000';

function App() {
  const [ideas, setIdeas] = useState([]);
  const [newIdea, setNewIdea] = useState('');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    fetchIdeas();
  }, []);

  const fetchIdeas = async () => {
    try {
      const response = await axios.get(`${API_URL}/ideas`);
      setIdeas(response.data);
    } catch (error) {
      console.error('Error fetching ideas:', error);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!newIdea.trim()) return;

    setLoading(true);
    try {
      await axios.post(`${API_URL}/ideas`, { content: newIdea });
      setNewIdea('');
      fetchIdeas();
    } catch (error) {
      console.error('Error submitting idea:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>Idea Board</h1>
      </header>

      <main className="App-main">
        <div className="idea-form">
          <h2>Submit a New Idea</h2>
          <form onSubmit={handleSubmit}>
            <textarea
              value={newIdea}
              onChange={(e) => setNewIdea(e.target.value)}
              placeholder="Enter your idea here..."
              rows="4"
              disabled={loading}
            />
            <button type="submit" disabled={loading || !newIdea.trim()}>
              {loading ? 'Submitting...' : 'Submit Idea'}
            </button>
          </form>
        </div>

        <div className="ideas-list">
          <h2>All Ideas</h2>
          {ideas.length === 0 ? (
            <p>No ideas yet. Be the first to submit one!</p>
          ) : (
            <ul>
              {ideas.map((idea) => (
                <li key={idea.id}>
                  <div className="idea-content">{idea.content}</div>
                  <div className="idea-date">
                    {new Date(idea.created_at).toLocaleDateString()}
                  </div>
                </li>
              ))}
            </ul>
          )}
        </div>
      </main>
    </div>
  );
}

export default App;