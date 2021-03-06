FROM ruby:2.3.1

MAINTAINER gnutovyury@gmail.com

RUN adduser --disabled-password --system --uid 1000 mocker

RUN echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

# copy dependecies description files
COPY Gemfile Gemfile.lock /home/mocker/app/
RUN chown -Rh mocker: /home/mocker

# install dependencies
USER mocker
WORKDIR /home/mocker/app
RUN bundle --deployment

# copy app sources
COPY . /home/mocker/app

# make app sources available to tester user
USER root
RUN chown mocker: -R ~mocker
USER mocker

CMD bundle exec script/start -p 8080

EXPOSE 8080
