FROM openjdk:17.0.2
WORKDIR /app
COPY run.sh /app/run.sh
COPY app.jar /app/app.jar
ENTRYPOINT ["/bin/bash"]
CMD ["-c", "/app/run.sh"]
