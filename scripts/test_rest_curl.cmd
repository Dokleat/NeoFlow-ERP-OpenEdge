@echo off
curl http://localhost:8810/neoflow/api/health
curl http://localhost:8810/neoflow/api/products
curl -X POST http://localhost:8810/neoflow/api/orders -H "Content-Type: application/json" -d "{ \"custId\": 1, \"lines\": [ {\"prodId\":1,\"qty\":\"2\",\"unitPrice\":\"4.50\"}, {\"prodId\":2,\"qty\":\"1\",\"unitPrice\":\"49.90\"} ] }"
