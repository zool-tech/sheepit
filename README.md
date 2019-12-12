## zooltech/sheepit
开源免费的分布式Blender渲染农场客户端镜像。sheepit-renderfarm网站：https://www.sheepit-renderfarm.com

## 使用：
```
docker run -d --name sheep zooltech/sheepit
```
通过参数使用自己注册的用户名密码：
```
docker run -d --name sheep -e si_name=你注册的用户名 -e si_pwd=你的密码 zooltech/sheepit
```
  参数说明：
  - si_name ： 在网站注册的用户名。例如：-e si_name=ztpub。
  - si_pwd ： 用户名对应的密码。例如：-e si_pwd=123456。
  - si_cpu ： 使用几颗CPU。缺省使用所有CPU。例如：-e si_cpu=4。
  - si_mem ： 使用内存大小。例如：-e si_mem=1024M 或 -e su_mem=8G 等。
  - si_reqtime ： 接受请求的时间范围。UTC时间。例如：-e si_reqtime=8:00-10:00,12:00-14:00,18:30-22:00。
