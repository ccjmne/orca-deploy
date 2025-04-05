FROM tomcat:9.0-jre8

# Clean up Tomcat example webapps
RUN rm -R ${CATALINA_HOME}/webapps

# Create setenv.sh for our Java web app and Tomcat, passing a set of environment variables the the JVM as system properties
COPY setenv.sh ${CATALINA_HOME}/bin/setenv.sh
RUN chmod 755 ${CATALINA_HOME}/bin/setenv.sh

# Push our custom Tomcat configuration files into the image
#   context.xml: BasicAuthenticator encoding configuration
#   web.xml:     CORS filter
#   server.xml:  User Realm
COPY context.xml server.xml web.xml ${CATALINA_HOME}/conf/

# Get the posgresql library used by our customised JDBC realm
RUN wget https://jdbc.postgresql.org/download/postgresql-42.7.1.jar \
	&& mv postgresql-42.7.1.jar ${CATALINA_HOME}/lib

# Embed our webapp(s) in the image -- last, so subsequent builds only update this step
ADD webapps ${CATALINA_HOME}/webapps

EXPOSE 8080

CMD ["catalina.sh", "run"]
