ASP.NET Skaffold Demo application
---
Development example for an ASP.NET API service in Kubernetes with Skaffold.

The Docker images are available in two flavors: debug and release.
To build them:
```shell
docker buildx build . --target debug -t skaffold-demo-debug
# or ...
docker buildx build . --target release -t skaffold-demo-release
```

To start developing with fast rebuild:
```shell
skaffold dev --port-forward
```
And open a browser on [http://127.0.0.1:8080](http://127.0.0.1:8080).