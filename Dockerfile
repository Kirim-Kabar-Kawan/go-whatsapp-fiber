FROM golang:1.16-alpine AS builder
#FROM golang:alpine

RUN apk update && apk add --no-cache git

# Move to working directory (/app).
WORKDIR /app

# Copy the code into the container.
COPY . .

# Swag
RUN go get -u github.com/swaggo/swag/cmd/swag
RUN swag init

# Download all the dependencies that are required in your source files and update go.mod file with that dependency.
# Remove all dependencies from the go.mod file which are not required in the source files.
RUN go mod tidy

# Build the application server.
# RUN go build -o binary .
ENV CGO_ENABLED=0 GOOS=linux GOARCH=amd64
RUN go build -ldflags="-s -w" -o apiserver .

FROM scratch

# Copy binary and config files from /build 
# to root folder of scratch container.
COPY --from=builder ["/app/apiserver", "/"]
# Command to run when starting the container.
ENTRYPOINT ["/apiserver"]
