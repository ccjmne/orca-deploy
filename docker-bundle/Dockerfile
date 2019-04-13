FROM tomcat:9.0.0.M10-jre8

# Clean up Tomcat example webapps
RUN rm -R ${CATALINA_HOME}/webapps

# Create setenv.sh for our Java web app and Tomcat, passing a set of environment variables the the JVM as system properties
COPY setenv.sh ${CATALINA_HOME}/bin/setenv.sh
RUN chmod 755 ${CATALINA_HOME}/bin/setenv.sh

# Replace existing web.xml with our customised version including a CORS filter
RUN rm ${CATALINA_HOME}/conf/web.xml
COPY ./web.xml ${CATALINA_HOME}/conf/web.xml

# Push our server.xml, which uses JVM properties to configure the user realm
RUN rm ${CATALINA_HOME}/conf/server.xml
COPY ./server.xml ${CATALINA_HOME}/conf/server.xml

# Get the posgresql library used by our customised JDBC realm
RUN wget https://jdbc.postgresql.org/download/postgresql-9.4.1211.jar \
	&& mv postgresql-9.4.1211.jar ${CATALINA_HOME}/lib

# Embed our webapp(s) in the image -- last, so subsequent builds only update this step
ADD webapps ${CATALINA_HOME}/webapps

EXPOSE 8080

CMD ["catalina.sh", "run"]
