FROM mcr.microsoft.com/playwright:v1.56.1-noble
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev
COPY src ./src
ENV BROWSER_CHANNEL=chromium HEADLESS=true BROWSER_PROFILE_DIR=/state/browser DATA_DIR=/state/data
# Persist /state and inject Telegram credentials as environment secrets.
CMD ["npm", "start"]
