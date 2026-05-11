FROM tomcat:10.1-jdk21
RUN rm -rf /usr/local/tomcat/webapps/*
COPY target/*.war /usr/local/tomcat/webapps/ROOT.war
RUN sed -i 's/port="8005"/port="-1"/' /usr/local/tomcat/conf/server.xml
ENV JAVA_OPTS="-Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager"
EXPOSE 8080
CMD ["catalina.sh", "run"]