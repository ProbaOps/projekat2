#FROM maven:3.8.5-openjdk-11-slim AS build
#RUN ls
#COPY src /home/app/src
#COPY pom.xml /home/app
#RUN mvn -f /home/app/pom.xml clean package -DskipTests
#
#FROM openjdk:11-alpine
#COPY --from=build /home/app/target/ProfileMicroservice-0.0.1-SNAPSHOT.jar /usr/local/lib/ProfileMicroservice-0.0.1-SNAPSHOT.jar
#ENTRYPOINT ["java","-jar","/usr/local/lib/profile-0.0.1-SNAPSHOT.jar"]
#
#
#
#
#FROM openjdk:11-jdk-alpine
#WORKDIR /app
#COPY target/profile-0.0.1-SNAPSHOT.jar ./
#EXPOSE 8080
#CMD java -jar profile-0.0.1-SNAPSHOT.jar




#Stage 1
# initialize build and set base image for first stage
FROM maven:3.6.3-adoptopenjdk-11 as stage1
# speed up Maven JVM a bit
ENV MAVEN_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"
# set working directory
WORKDIR /opt/demo
# copy just pom.xml
COPY ./pom.xml .
# go-offline using the pom.xml
RUN mvn dependency:go-offline
# copy your other files
COPY ./src ./src
# compile the source code and package it in a jar file
RUN mvn clean install -Dmaven.test.skip=true
#Stage 2
# set base image for second stage
FROM adoptopenjdk/openjdk11:jre-11.0.9_11-alpine
# set deployment directory
WORKDIR /opt/demo
# copy over the built artifact from the maven image
COPY --from=stage1 /opt/demo/target/profile-0.0.1-SNAPSHOT.jar /opt/demo
ENV activeProfile = "-Dspring.profiles.active=docker"
ENTRYPOINT ["java","-jar","profile-0.0.1-SNAPSHOT.jar"]