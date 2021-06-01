FROM quay.io/rhdevelopers/quarkus-java-builder as builder
COPY . /project
WORKDIR /project
# uncomment this to set the MAVEN_MIRROR_URL of your choice, to make faster builds
# ARG MAVEN_MIRROR_URL=<your-maven-mirror-url>
# e.g.
#ARG MAVEN_MIRROR_URL=http://192.168.64.1:8081/nexus/content/groups/public

RUN /usr/local/bin/entrypoint-run.sh mvn -DskipTests clean package

FROM fabric8/java-jboss-openjdk8-jdk:1.5.4
USER jboss
ENV JAVA_APP_DIR=/deployments

COPY --from=builder /project/target/lib/* /deployments/lib/
COPY --from=builder /project/target/*-runner.jar /deployments/app.jar

ENTRYPOINT [ "/deployments/run-java.sh" ]
