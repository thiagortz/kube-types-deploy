FROM python:3.7-slim

COPY api /app
COPY Pipfile  /app
COPY Pipfile.lock /app

WORKDIR /app

RUN pip install --upgrade pip
RUN pip install pipenv
RUN pipenv install --dev --system --deploy

ENTRYPOINT ["python"]

CMD [ "run.py" ]