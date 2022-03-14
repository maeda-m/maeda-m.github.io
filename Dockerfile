ARG RUBY_VERSION
FROM ruby:${RUBY_VERSION}-buster

WORKDIR /jekyll/docs

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "bundle", "exec", "jekyll", "serve", "--force_polling", "--host", "0.0.0.0" ]
