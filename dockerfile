FROM alibaba-cloud-linux-3-registry.cn-hangzhou.cr.aliyuncs.com/alinux3/node:16.17.1-nslt

USER root
RUN mkdir -p /app && chown -R node:node /app

WORKDIR /app
COPY package*.json ./
RUN chown -R node:node /app

USER node
RUN npm install --production

USER root
COPY . .
RUN chown -R node:node /app

USER node
EXPOSE 3000
CMD ["node", "index.js"]
