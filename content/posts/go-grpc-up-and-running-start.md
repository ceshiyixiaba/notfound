+++
title = "《gRPC 与云原生应用开发》开发环境"
author = ["likui"]
date = 2021-03-31T19:41:00+08:00
lastmod = 2021-03-31T19:43:31+08:00
tags = ["go", "grpc"]
draft = false
+++

## 《gRPC 与云原生应用开发》开发环境 {#grpc-与云原生应用开发-开发环境}

-   go 1.16.2
-   protoc 3.15.6

《gRPC 与云原生应用开发》示例代码与当前版本有些许变化。


### 安装 {#安装}

```bash
# manjaro
sudo pacman -S protobuf

go get -u google.golang.org/protobuf/cmd/protoc-gen-go
go get -u google.golang.org/grpc/cmd/protoc-gen-go-grpc
```


### 目录结构 {#目录结构}

```text
ch02/productinfo/proto/product_info.proto

ch02/productinfo/go/go.sum
ch02/productinfo/go/go.mod

ch02/productinfo/go/ecommerce/product_info_grpc.pb.go
ch02/productinfo/go/ecommerce/product_info.pb.go

ch02/productinfo/go/client/main.go
ch02/productinfo/go/server/main.go
```


### 依赖 {#依赖}

在 `ch02/productinfo/go` 目录下执行：

```bash
go mod init productinfo

go get google.golang.org/grpc@latest
go get github.com/gofrs/uuid@latest
go get google.golang.org/protobuf@latest
```


### Protocol Buffers {#protocol-buffers}

新建文件 `ch02/productinfo/proto/product_info.proto` ：

```protobuf
syntax = "proto3";

package ecommerce;

// NOTE 需要添加 go_package
option go_package = "productinfo/ecommerce";

service ProductInfo {
  rpc addProduct(Product) returns (ProductID);
  rpc getProduct(ProductID) returns (Product);
}

message Product {
  string id = 1;
  string name = 2;
  string description = 3;
}

message ProductID {
  string value = 1;
}
```

-   需要添加 go\_package


#### 生成代码 {#生成代码}

在 `ch02/productinfo/go`  目录下执行

```bash
protoc --go_out=ecommerce \
       --go_opt=paths=source_relative \
       --go-grpc_out=ecommerce \
       --go-grpc_opt=paths=source_relative \
       -I ../proto product_info.proto
```


### Server {#server}

新建文件 `ch02/productinfo/go/server/main.go` ：

```go
package main

import (
  "context"
  "log"
  "net"
  pb "productinfo/ecommerce"

  "github.com/gofrs/uuid"
  "google.golang.org/grpc"
  "google.golang.org/grpc/codes"
  "google.golang.org/grpc/status"
)

type server struct {
  productMap map[string]*pb.Product
  // NOTE 需要添加 unimplementedproductinfoserver
  pb.UnimplementedProductInfoServer
}

func (s *server) AddProduct(ctx context.Context, in *pb.Product) (*pb.ProductID, error) {
  out, err := uuid.NewV4()
  if err != nil {
    return nil, status.Errorf(codes.Internal, "Error while generating Product ID", err)
  }

  in.Id = out.String()
  if s.productMap == nil {
    s.productMap = make(map[string]*pb.Product)
  }
  s.productMap[in.Id] = in

  return &pb.ProductID{Value: in.Id}, status.New(codes.OK, "").Err()
}

func (s *server) GetProduct(ctx context.Context, in *pb.ProductID) (*pb.Product, error) {
  value, exists := s.productMap[in.Value]
  if exists {
    return value, status.New(codes.OK, "").Err()
  }

  return nil, status.Errorf(codes.NotFound, "Product does not exist.", in.Value)
}

const (
  port = ":50051"
)

func main() {
  lis, err := net.Listen("tcp", port)
  if err != nil {
    log.Fatalf("failed to listen: %v", err)
  }
  s := grpc.NewServer()
  pb.RegisterProductInfoServer(s, &server{})

  log.Printf("Starting gRPC listener o port " + port)
  if err := s.Serve(lis); err != nil {
    log.Fatalf("failed to serve: %v", err)
  }
}
```

-   需要添加 unimplementedproductinfoserver


### Client {#client}

新建文件 `ch02/productinfo/go/client/main.go` ：

```go
package main

import (
  "context"
  "log"
  "time"

  pb "productinfo/ecommerce"

  "google.golang.org/grpc"
)

const (
  address = ":50051"
)

func main() {
  conn, err := grpc.Dial(address, grpc.WithInsecure())
  if err != nil {
    log.Fatalf("did not connect: %v", err)
  }
  defer conn.Close()

  c := pb.NewProductInfoClient(conn)

  ctx, cancel := context.WithTimeout(context.Background(), time.Second)
  defer cancel()

  name := "Apple iPhone 11"
  description := "Meet Apple iPhone 11. All-new dual-camera system with Ultra Wide and Night mode."
  r, err := c.AddProduct(ctx, &pb.Product{Name: name, Description: description})
  if err != nil {
    log.Fatalf("Could not add product: %v", err)
  }
  log.Printf("Product ID : %s added successfully", r.Value)

  product, err := c.GetProduct(ctx, &pb.ProductID{Value: r.Value})
  if err != nil {
    log.Fatalf("Could not get product: %v", err)
  }
  log.Printf("Product %v", product.String())
}
```


### 参考 {#参考}

-   《gRPC 与云原生应用开发》
-   <https://github.com/grpc-up-and-running/samples.git>
-   <https://grpc.io/docs/languages/go/quickstart/>
-   <https://developers.google.com/protocol-buffers/docs/reference/go-generated#package>
-   <https://github.com/grpc/grpc-go/issues/3669>
-   <https://github.com/grpc/grpc-go/issues/3794>
