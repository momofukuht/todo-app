FROM node:20-alpine

WORKDIR /app

RUN corepack enable && corepack prepare yarn@1.22.19 --activate

COPY package.json ./
RUN yarn install

COPY . .

EXPOSE 5173

CMD ["yarn", "dev", "--host"]
