FROM golang:1.17-alpine

# Set the Current Working Directory inside the container
WORKDIR /app

COPY go.mod ./
COPY go.sum ./
# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download
# Copy the source from the current directory to the Working Directory inside the container
COPY . ./
# RUN go run ./worker/main.go

RUN go build -o ./main
CMD ["./main" ]



