FROM python

ENV APP_HOME /app
COPY . $APP_HOME
WORKDIR $APP_HOME

RUN pip install Flask

ENTRYPOINT ["python"]
CMD ["app.py"]
