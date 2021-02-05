package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"time"

	"github.com/greenvine/hey-grpc-starter-client/maths"

	"google.golang.org/grpc"
)

func serve(serverAddress string) error {
	// Create gRPC connection
	conn, err := grpc.Dial(serverAddress, grpc.WithInsecure())
	if err != nil {
		return err
	}
	defer func() {
		if connErr := conn.Close(); connErr != nil {
			log.Fatalf("failed to close the connection: %v", connErr)
		}
	}()

	// Create context
	ctx, cancel := context.WithTimeout(context.Background(), time.Minute)
	defer cancel()

	if invocationErr := invokeCounter(ctx, conn, 1024); invocationErr != nil {
		return invocationErr
	}

	return nil
}

func invokeCounter(ctx context.Context, conn *grpc.ClientConn, repeats int) error {
	var (
		currentStep   uint64
		invocationErr error
	)

	client, err := maths.NewCounterClient(conn)
	if err != nil {
		return err
	}

	for i := 0; i < repeats; i++ {
		currentStep, invocationErr = client.IncrementCounter(ctx, 1)
		if invocationErr != nil {
			return invocationErr
		}

		fmt.Printf("[%s] current value: %d\n", time.Now().UTC().Format(time.RFC3339Nano), currentStep)
	}

	return nil
}

func main() {
	serverAddress := flag.String("server", "localhost:3000", "server address")
	flag.Parse()

	if err := serve(*serverAddress); err != nil {
		log.Fatalf("failed to connect to the server: %s", err.Error())
	}
}
