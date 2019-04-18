FROM docker.io/fabric8/java-jboss-openjdk8-jdk:1.5.4
USER jboss
ENV JAVA_APP_DIR=/deployments

EXPOSE 8080

COPY target/lib/* /deployments/lib/
COPY target/*-runner.jar /deployments/app.jar

ENTRYPOINT [ "/deployments/run-java.sh" ]
