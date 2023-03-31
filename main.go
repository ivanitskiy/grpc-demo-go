package main

import (
	"context"
	"flag"
	"net"

	"github.com/golang/glog"
	extUser "github.com/ivanitskiy/grpc-demo-go/pbgen/schema/user"
	"google.golang.org/grpc"
)

var (
	addr    = flag.String("addr", ":9090", "endpoint of the gRPC service")
	network = flag.String("network", "tcp", "a valid network type (tcp, tcp4, tcp6, unix or unixpacket) which is consistent to -addr")
)

type userServiceServer struct {
	//  by defult unimplemented rpc
	extUser.UnimplementedUserServiceServer
}

func newUserServiceServer() extUser.UserServiceServer {
	return new(userServiceServer)
}

// Run starts the example gRPC service.
func Run(ctx context.Context, network, address string) error {
	l, err := net.Listen(network, address)
	if err != nil {
		return err
	}
	glog.Info("Started gRPC listener %S:%S", network, address)
	defer func() {
		if err := l.Close(); err != nil {
			glog.Errorf("Failed to close %s %s: %v", network, address, err)
		}
	}()

	s := grpc.NewServer()
	extUser.RegisterUserServiceServer(s, newUserServiceServer())

	go func() {
		defer s.GracefulStop()
		<-ctx.Done()
	}()
	return s.Serve(l)
}

func main() {
	flag.Parse()
	defer glog.Flush()
	ctx := context.Background()
	if err := Run(ctx, *network, *addr); err != nil {
		glog.Fatal(err)
	}
}
