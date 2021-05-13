FROM quay.io/rhdevelopers/quarkus-java-builder:graal-1.0.0-rc15 as builder
COPY . /project

# uncomment this to set the MAVEN_MIRROR_URL of your choice, to make faster builds
# ARG MAVEN_MIRROR_URL=<your-maven-mirror-url>
# e.g.
# ARG MAVEN_MIRROR_URL=http://192.168.64.1:8081/nexus/content/groups/public

RUN /usr/local/bin/entrypoint-run.sh mvn -DskipTests clean package -Pnative

FROM registry.fedoraproject.org/fedora-minimal

COPY --from=builder /project/target/helloworld-java-quarkus-1.0-SNAPSHOT-runner /app

ENTRYPOINT [ "/app" ]
