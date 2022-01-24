# Package explorer

Application to show packages and their dependencies in host system. 

Server to read packages and serve them over Http API. Listing of all packages is available in `/packages`. Details about specific are available from `/packages/<package-id>`


Client to display packages from API.



## Requirements
### Server
* [Java](https://www.java.com/en/download/manual.jsp)
* [SBT](https://www.scala-sbt.org/download.html)

Server is expected to run on Ubuntu or Debian host.

### Client
* [Create Elm App](https://github.com/halfzebra/create-elm-app)



## Running locally

Run the server with (http://localhost:8080)
``` sh
cd server
sbt ~reStart
```

Run the development server with (http://localhost:3000):
```sh
cd client
elm-app start
```
