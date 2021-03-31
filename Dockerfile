FROM ruby:2.5.3

RUN apt-get update -qq

# Ruby prerequisites
WORKDIR /src
RUN apt-get install -y wget
RUN wget -O ruby-install-0.7.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.7.0.tar.gz
RUN tar -xzvf ruby-install-0.7.0.tar.gz
WORKDIR /src/ruby-install-0.7.0/
RUN apt-get install -y make
RUN make install

# TODO install Ruby manually with ruby-install:
# Install a modern version of Ruby
# RUN ruby-install ruby 2.5.3
# ENV PATH /opt/rubies/ruby-2.5.3/bin:$PATH

# Install gems
WORKDIR /foundation
ADD Gemfile* /foundation/
RUN gem install bundler
RUN bundle install
RUN echo 'alias create_docs="RAILS_ENV=test bundle exec rake rswag:specs:swaggerize PATTERN="spec/integration/\*\*/\*_spec.rb""' >> ~/.bashrc
RUN echo 'alias rls="bundle exec rails"' >> ~/.bashrc
RUN echo 'alias rspec_test="RAILS_ENV=test bundle exec rspec"' >> ~/.bashrc

# Add code for a generic Assemble Foundation
ADD . /foundation/

# Always `bundle exec ...` our commands,
# to make sure we're using the right versions of our dependencies.
ENTRYPOINT ["bundle", "exec"]

# Default startup command
CMD rails s -b 0.0.0.0 -p $PORT
