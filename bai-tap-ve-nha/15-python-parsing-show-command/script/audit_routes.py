#!/usr/bin/env python3
import subprocess
import json

ROUTERS = ["r1", "r2", "r3", "r4"]
LAN_SUBNETS = ["10.0.1.0/24", "10.0.2.0/24"]


def get_routes(container):
    """Trả về list các route (dict) của 1 container, lấy qua `ip -j route show`."""
    # TODO: dùng subprocess.run để chạy:
    #   docker exec <container> ip -j route show
    # capture_output=True, text=True, rồi json.loads(...stdout) để parse.
    pass


def main():
    for router in ROUTERS:
        routes = get_routes(router)
        # TODO: lấy tập hợp các giá trị "dst" trong routes (bỏ qua "default")
        dsts = set()

        for subnet in LAN_SUBNETS:
            status = "OK" if subnet in dsts else "MISSING"
            print(f"{router}: {subnet} -> {status}")


if __name__ == "__main__":
    main()
