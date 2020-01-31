## Stage 1 : build with maven builder image with native capabilities
FROM quay.io/quarkus/ubi-quarkus-native-s2i:19.3.1-java8 AS build
COPY ["settings.gradle","gradle.properties","build.gradle","/usr/src/app/"]
COPY ["src","/usr/src/app/"]
USER root
RUN chown -R quarkus /usr/src/app
USER quarkus
WORKDIR /usr/src/app
RUN gradle buildNative --debug --stacktrace

## Stage 2 : provide minmal image containing curl
FROM hectormolinero/curl:v17-amd64 AS curl

## Stage 3 : create the docker final image
FROM registry.access.redhat.com/ubi8/ubi-minimal
WORKDIR /work/
COPY --from=build /usr/src/app/build/*-runner /work/application
COPY --from=curl /curl /curl
RUN chmod 775 /work
EXPOSE 8080
CMD ["./application", "-Dquarkus.http.host=0.0.0.0"]