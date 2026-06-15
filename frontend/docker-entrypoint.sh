#!/bin/sh
set -e

# Function to replace environment variables in JavaScript files
inject_env_vars() {
  echo "Injecting environment variables..."

  # Create a JavaScript file with runtime configuration
  cat > /usr/share/nginx/html/env-config.js <<EOF
window._env_ = {
  REACT_APP_API_URL: "${REACT_APP_API_URL:-http://localhost:8000}",
  REACT_APP_ENVIRONMENT: "${REACT_APP_ENVIRONMENT:-development}"
};
EOF

  echo "Environment variables injected successfully"
}

# Inject environment variables
inject_env_vars

# Start nginx
exec nginx -g 'daemon off;'