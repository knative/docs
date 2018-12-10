FROM dyalog/dyalog:17.1
ENTRYPOINT []

RUN apt-get update && apt-get install dos2unix && apt-get install --assume-yes git

RUN git clone https://github.com/mvranic/JSONServer.git /JSONServer # Markos JSON Server with thread control.

ENV APP_HOME /apphome
COPY . $APP_HOME
RUN chmod -R 777 $APP_HOME
RUN find $APP_HOME -type f  \( -name '*.sh' -o -name '*.apl' -o -name '*.dyalog' \) -print0 | xargs -0 dos2unix
WORKDIR $APP_HOME

# Configure and document the service HTTP port.
ENV PORT 8080
EXPOSE $PORT

# Run the web service on container startup.
CMD ["sh","init.sh"]