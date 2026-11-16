# -*- coding: utf-8 -*-
# pip3 install semver

"""
Github Action 自动化脚本

此脚本用于 CI 自动化发布打包工作
"""


# 引入自定义的打包发布模块和环境设置模块
import subprocess

from plib.publish import run


def main() -> None:
    subprocess.run(["lua", "tests/team_mon_compute.lua"], check=True)
    run("ci")


if __name__ == "__main__":
    main()
