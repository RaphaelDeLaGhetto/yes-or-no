yes-or-no
=========

Simple visual _Yes or No_ application built on [Padrino](http://padrinorb.com/).
Submit image links and present to allow users to repond _Yes_ or _No_.

# Configuration

Create a `.env` file:

```
touch .env
```

Paste and save the following:

```
# Mailer
EMAIL=someguy@example.com
SMTP_ADDRESS=127.0.0.1
SMTP_PORT=1025
EMAIL_USERNAME=
EMAIL_PASSWORD=
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

## Server

```
padrino start -h 0.0.0.0
```


