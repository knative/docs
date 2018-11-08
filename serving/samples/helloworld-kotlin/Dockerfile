FROM gradle

ADD build.gradle ./build.gradle
ADD src ./src
RUN gradle clean build
ENTRYPOINT ["java","-jar","-Djava.security.egd=file:/dev/./urandom","/home/gradle/build/libs/gradle.jar"]

