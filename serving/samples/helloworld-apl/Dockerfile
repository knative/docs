FROM dyalog/dyalog:17.1

RUN apt-get update
RUN apt-get install dos2unix

ADD init /init
RUN find /init -type f -print0 | xargs -0 dos2unix

ADD run-script.sh /run-script.sh
RUN dos2unix /run-script.sh

ENV APP_HOME /aplcode
COPY . $APP_HOME
RUN find /aplcode -type f  \( -name '*.apl' -o -name '*.dyalog' \) -print0 | xargs -0 dos2unix
WORKDIR $APP_HOME

RUN git clone https://github.com/mvranic/JSONServer.git /JSONServer # Markos JSON Server with thread control.

ENTRYPOINT ["sh","/run-script.sh"]