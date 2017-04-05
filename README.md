yes-or-no
=========

Simple visual _Yes or No_ application built on [Padrino](http://padrinorb.com/).
Submit image links and present to allow users to repond _Yes_ or _No_.

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

## Test

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


