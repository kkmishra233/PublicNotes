# commands

**Install earthly:**
```bash
sudo /bin/sh -c 'wget [https://github.com/earthly/earthly/releases/latest/download/earthly-linux-amd64 -O /usr/local/bin/earthly](https://github.com/earthly/earthly/releases/latest/download/earthly-linux-amd64%20-O%20/usr/local/bin/earthly) && chmod +x /usr/local/bin/earthly && /usr/local/bin/earthly bootstrap --with-autocomplete'
```

**Run earthly build:**
```bash
earthly +all --use-inline-cache  --save-inline-cache
```

Run
```bash
docker run -p 8080:8080 kafka-ui:latest
```

Access:
```bash
http://localhost:8080/
```

## COPY multiple dir at one:
```bash
COPY dir1 dir1
COPY dir2 dir2
COPY dir3 dir3

as

COPY --dir dir1 dir2 dir3 ./
```

## support if else 
```bash
ARG TARGETPLATFORM
IF [ "$TARGETPLATFORM" = "linux/arm64" ]
    FROM --platform=linux/arm64 registry.access.redhat.com/ubi8/openjdk-17
ELSE
    FROM --platform=linux/amd64 registry.access.redhat.com/ubi8/openjdk-17
END
```

## run integration tests 
```bash
integration-tests:
    FROM earthly/dind:alpine
    COPY docker-compose.yml ./
    WITH DOCKER --compose docker-compose.yml --load tests:latest=+test-setup
        RUN docker run tests:latest
    END

or

FROM alpine:3.15
ARG run_locally=false
IF [ "$run_locally" = "true" ]
    LOCALLY
ELSE
    FROM earthly/dind:alpine
    WORKDIR /app
    COPY docker-compose.yml ./
END
WITH DOCKER --compose docker-compose.yml \
        --service db \
        --load=+integration-test
    RUN docker-compose up integration
END
```