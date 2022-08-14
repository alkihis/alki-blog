FROM node:18.7.0-alpine3.15

RUN apk --no-cache add --virtual native-deps \
  curl openssl g++ gcc libgcc libstdc++ linux-headers autoconf automake make nasm git py-pip glances htop && \
  yarn global add node-gyp typescript rimraf

RUN mkdir /app
WORKDIR /app

ADD . .

RUN yarn global add hexo-cli
RUN yarn --production=false
RUN yarn build

EXPOSE 4000

CMD ["yarn", "server", "-s"]
