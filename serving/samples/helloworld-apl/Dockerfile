FROM dyalog/dyalog:17.1
# Adjusting Dyalog image:
# RRR: "run" is standard Linux folder!
RUN rm /run
# Entry point is not needed in Dyalog image.
ENTRYPOINT []

# Install dos2unix and git:
RUN apt-get update
RUN apt-get install dos2unix && apt-get install --assume-yes git

# Markos JSON Server with thread control:
RUN git clone https://github.com/mvranic/JSONServer.git /JSONServer 

# Coping APL code and startup shell scripts to image:
ENV APP_HOME /apphome
COPY . $APP_HOME
# Change mode for shell scripts:
RUN find $APP_HOME -type f -iname "*.sh" -exec chmod +x {} \;
# Format the text files:
RUN find $APP_HOME -type f  \( -iname '*.sh' -o -iname '*.apl' -o -iname '*.dyalog' \) -print0 | xargs -0 dos2unix

# Standard knative settings:
WORKDIR $APP_HOME

# Configure and document the service HTTP port.
ENV PORT 8080
EXPOSE $PORT

# Run the web service on container startup.
CMD ./init.sh