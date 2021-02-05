package maths

import (
	"context"
	"fmt"

	maths "github.com/greenvine/hey-grpc-starter-interface/gen/go/maths/v1"
	"google.golang.org/grpc"
)

type CounterAPIClient struct {
	service maths.CounterAPIClient
}

func NewCounterClient(conn *grpc.ClientConn) (*CounterAPIClient, error) {
	if conn == nil {
		return nil, fmt.Errorf("invalid gRPC connection")
	}

	client := maths.NewCounterAPIClient(conn)
	return &CounterAPIClient{client}, nil
}

func (c *CounterAPIClient) IncrementCounter(ctx context.Context, step uint64) (uint64, error) {
	req := &maths.IncrementCounterRequest{Step: step}

	res, err := c.service.Increment(ctx, req)
	if err != nil {
		return 0, err
	}
	return res.GetValue(), nil
}
