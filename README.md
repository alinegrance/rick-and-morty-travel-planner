# Rick and Morty Travel Planner API

It is a travel planning through the Rick and Morty Universe API written in Crystal, backed by kemalcr and MySQL.

## Usage

To get started, simply run:

```shell
docker-compose up -d
```

It will start the API container and a MySQL container, both attached to the same network.
The API container starts with a listening server on port 3000, and can also be accessed locally
(through `localhost:3000`).

The settings for the MySQL container can be changed via environment variables (see the `docker-compose.yml` file).
The MySQL container executes the script placed into the `docker-entrypoint-initdb.d` directory which recreates the
database empty.

## Running tests

To run the tests, you need to have Crystal language installed. Follow the steps [here](https://crystal-lang.org/install/).
Once you have Crystall installed, please run

```shell
crystal spec
```

If you rather not install Crystal locally, you can also run the tests inside the container created
by docker-compose by running

```shell
docker exec -it milenio_challenge crystal spec
```

## Postman

You can also run a collection of requests using Postman. To do this, import the collection file `postman.json` into
Postman and run the requests while the docker-compose is up.

- [Aline Grance](https://github.com/alinegrance) - creator and maintainer
