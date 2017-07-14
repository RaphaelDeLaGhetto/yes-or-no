yes-or-no
=========

Simple visual _Yes or No_ application built on [Padrino](http://padrinorb.com/).
Submit image links and present to allow users to respond _Yes_ or _No_.

# Host dependencies

This is needed for the `pg` gem.

```
sudo apt install libpq-dev
```

Headless browser for testing:

```
sudo wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2
sudo tar xvjf phantomjs-2.1.1-linux-x86_64.tar.bz2 -C /usr/local/share/
sudo ln -s /usr/local/share/phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin/
```

Verify `phantomjs` installation:

```
phantomjs --version
```

You may need to log in and out of the shell for this to work.

# Configuration

Create a `.env` file:

```
touch .env
```

Paste and save the following:

```
# General
HOST=http://localhost

# API
HMAC_SECRET=my$ecretK3y

# Mailer
EMAIL=someguy@example.com
SMTP_ADDRESS=127.0.0.1
SMTP_PORT=1025
EMAIL_USERNAME=
EMAIL_PASSWORD=

# App
QUESTION="Is this app useful?"

# Points
POST_POINTS=10
VOTE_POINTS=2
YES_POINTS=3
NO_POINTS=-1

# For testing purposes, leave this false or don't set
#AUTO_APPROVE=false
# For testing purposes, leave this unset
#NOTIFICATION_EMAIL=someotherguy@example.com

# Set the frequency of ad blocks (default 0)
#AD_SPACING=0
```

The mailer configuration provided works with `mailcatcher`.

# Development

## Set up

```
bundle install
```

## Database

### Docker Postgres

This is only intended for development:

```
docker run --name yesorno-postgres -e POSTGRES_USER=root -p 5432:5432 -d postgres
```

#### Debug container

```
docker exec -it yesorno-postgres bash
> psql -U root
```

### Create/Migrate

```
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake db:seed
```

## Email

Start up `mailcatcher` to see what's being sent out:

```
bundle exec mailcatcher
```

This runs as a daemon. Go to the web console (http://127.0.0.1:1080) to look at emails and terminate the program.


# Test

## Dependencies

Install `phantomjs`. It was already installed in my current Ubuntu 14.04, so I'm not sure about `apt` or other dependencies.

### Create/migrate test database

```
bundle exec rake db:create RACK_ENV=test
bundle exec rake db:migrate RACK_ENV=test
```

### Execute

```
bundle exec rspec
```

Run one test:

```
RACK_ENV=test bundle exec rspec spec/features/landing_page_spec.rb

```

## Server

```
padrino start -h 0.0.0.0
```

# Production

## Heroku

```
heroku create
git push heroku master
```

This should be setup to work with Heroku out of the box (with the exception of mail configuration). Heroku specific dependencies are listed in the `:heroku` group in the `Gemfile`. As such, `RACK_ENV` config variable needs to be set to `heroku`. Once set,

```
heroku run bundle exec rake db:migrate
heroku run bundle exec rake db:seed
```

## `rake` bulk insert

Put images to be inserted in a directory under `./public`.

```
RACK_ENV=production bundle exec post:images['someguy@example.com', './public/path/to/images']
```

