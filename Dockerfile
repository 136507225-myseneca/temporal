FROM golang:alpine
ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64
# Set the Current Working Directory inside the container
WORKDIR /app
COPY go.mod ./
COPY go.sum ./
# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download
RUN go mod tidy
# Copy the source from the current directory to the Working Directory inside the container
COPY . ./
RUN go run ./worker/main.go
RUN go run ./starter/main.go