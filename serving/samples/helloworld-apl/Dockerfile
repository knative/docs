FROM dyalog/dyalog:17.1

RUN apt-get update
RUN apt-get install dos2unix
RUN apt-get install --assume-yes git

RUN git clone https://github.com/mvranic/JSONServer.git /JSONServer # Markos JSON Server with thread control.

ENV APP_HOME /apphome
COPY . $APP_HOME
RUN find $APP_HOME -type f  \( -name '*.sh' -o -name '*.apl' -o -name '*.dyalog' \) -print0 | xargs -0 dos2unix
WORKDIR $APP_HOME

ENTRYPOINT ["sh","init.sh"]