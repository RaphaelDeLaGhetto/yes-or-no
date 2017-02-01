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
docker exec -it yes_or_no_postgres_1 bash
> psql -U yes_or_no
```

### Create/Migrate

```
bundle exec rake db:create
```

## Test

```
bundle exec rspec
```

## Server

```
padrino s
```


