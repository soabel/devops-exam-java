FROM openjdk:11-jre
COPY ./target/exam-0.0.1-SNAPSHOT.jar /usr/app/
WORKDIR /usr/app
RUN sh -c 'touch exam-0.0.1-SNAPSHOT.jar'
ENTRYPOINT ["java","-jar","exam-0.0.1-SNAPSHOT.jar"]