# 关于本fork

这个版本更新了 ctranslate2 到 4.6.2 以支持 cuda 12.x 和 cudnn 9.x ，大大提高了 RTX 50 系列显卡的推理速度（原版 v0.6.8 转录 5 分钟左右音频需要 56 秒，更新后转录平均不到10秒）

该版本以docker镜像形式提供，可以通过 [papersman/kikoeru-translator:latest](https://hub.docker.com/repository/docker/papersman/kikoeru-translator) 来拉取.

具体使用方法请参考 [DOCKER_INSTRUCTIONS.md](DOCKER_INSTRUCTIONS.md) 和 [docker-compose.yml.example](docker-compose.yml.example)

以上修改在 RTX 5070ti + wsl2（宿主机cuda_13.0，cudnn 9.17.1）下测试通过.

注意：该版本使用 pyinstaller 打包始终失败（原因未知），因此无法提供可执行文件，十分抱歉。从源码运行是没有问题的。

# 更新记录

## v0.6.8
支持largev2 3500h版本的微调模型，感谢 @海南鸡饭 分享的模型权重，感谢 @rancekk 提供的代码改动