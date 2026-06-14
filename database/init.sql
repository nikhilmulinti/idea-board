-- Create the ideas table if it doesn't exist
CREATE TABLE IF NOT EXISTS ideas (
    id SERIAL PRIMARY KEY,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert some sample data
INSERT INTO ideas (content) VALUES
    ('Build a cloud-agnostic DevOps platform'),
    ('Implement AI-powered CI/CD pipeline'),
    ('Create reusable Terraform modules'),
    ('Automate deployments with GitHub Actions'),
    ('Add intelligent health checks and rollbacks')
ON CONFLICT DO NOTHING;