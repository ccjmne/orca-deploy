FROM tomcat:9.0.0.M10-jre8

ARG DB_HOST
ARG DB_NAME
ARG DB_USER
ARG DB_PASS
ARG AWS_ACCESS
ARG AWS_SECRET
ARG DEMO
ARG MEMORY

# Clean up Tomcat example webapps
RUN rm -R ${CATALINA_HOME}/webapps/*

# Embed our api and ui in the image for PROD RELEASES only
#COPY api.war ${CATALINA_HOME}/webapps/api.war
#ADD build ${CATALINA_HOME}/webapps/ROOT

# Install our keystore on the virtual machine
RUN mkdir /root/ssl
COPY ./star_formationssecurite_fr.jks /root/ssl/star_formationssecurite_fr.jks

# Create setenv.sh for our Java web app
RUN echo "CATALINA_OPTS=\"-Ddb_user=${DB_USER} -Ddb_pass=${DB_PASS} -Ddb_host=${DB_HOST} -Ddb_name=${DB_NAME} -Daws.accessKeyId=${AWS_ACCESS} -Daws.secretKey=${AWS_SECRET} -Ddemo=${DEMO} ${MEMORY}\";" \
	> ${CATALINA_HOME}/bin/setenv.sh \
	&& chmod 755 ${CATALINA_HOME}/bin/setenv.sh

# Replace existing web.xml with our customised version including a CORS filter
RUN rm ${CATALINA_HOME}/conf/web.xml
COPY ./web.xml ${CATALINA_HOME}/conf/web.xml

# Push our server.xml template, edit it according to the environment variables and replace existing server.xml
COPY ./server.xml ${CATALINA_HOME}/conf/server-template.xml
RUN rm ${CATALINA_HOME}/conf/server.xml
RUN cat ${CATALINA_HOME}/conf/server-template.xml \
	| sed -re "s@<Realm />@<Realm className=\"org.apache.catalina.realm.JDBCRealm\"\n\tconnectionName=\"${DB_USER}\"\n\tconnectionPassword=\"${DB_PASS}\"\n\tconnectionURL=\"jdbc:postgresql://${DB_HOST}:5432/${DB_NAME}\"\n\tdriverName=\"org.postgresql.Driver\"\n\tuserTable=\"users\"\n\tuserNameCol=\"user_id\"\n\tuserCredCol=\"user_pwd\"\n\tuserRoleTable=\"users_roles\"\n\troleNameCol=\"usro_type\"><CredentialHandler className=\"org.apache.catalina.realm.MessageDigestCredentialHandler\" algorithm=\"md5\" /></Realm>@" \
	> ${CATALINA_HOME}/conf/server.xml
RUN rm ${CATALINA_HOME}/conf/server-template.xml

# Get the posgresql library used by our customised JDBC realm
RUN wget https://jdbc.postgresql.org/download/postgresql-9.4.1211.jar \
	&& mv postgresql-9.4.1211.jar ${CATALINA_HOME}/lib

EXPOSE 8443

CMD ["catalina.sh", "run"]
