FROM python:3.8
#COPY ../FlaskApplication/requirements.txt .
COPY requirements.txt .
RUN pip install -r requirements.txt
WORKDIR /churn_prediction
COPY . /churn_prediction
WORKDIR /churn_prediction
RUN mkdir -p logs #, touch logs/error.log
RUN ["chmod", "+x", "/churn_prediction/gunicorn.sh"]
EXPOSE 5000
#ENTRYPOINT ["./gunicorn.sh"]
ENTRYPOINT ["bash", "/churn_prediction/gunicorn.sh"]