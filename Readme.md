### 中文界面设置

- 修改`bin/jmeter.properties`文件，将`language`设置为`zh_CN`。
  ```
  #Preferred GUI language. Comment out to use the JVM default locale's language.
  language=zh_CN
  ```

### 利用jmeter代理服务器进行脚本录制

1. 在`测试计划`中添加`线程组`
  - 线程数：就是模仿用户并发的数量，Ramp-up:运行线程的总时间，单位是秒，循环次数：就是每个线程循环多少次。
  - 我现在的线程数是200，就是相当于有200个用户，运行线程的总时间是10秒。也就是说在这10秒中之内200个用户同时访问，一秒钟有20个用户同时访问，每个用户循环一次，也就是访问一次。
![](https://upload-images.jianshu.io/upload_images/3986094-5121ec5fe11dcc10.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/800)


1. 在`测试计划`中添加`非测试元件` → `http代理服务器`
1. 端口（代理服务器监听端口）：可另外设置端口，默认8888
  - 目标控制器：`测试计划 > 线程组`
  - 分组：`每个组放入一个新的控制器`
  - 勾选：`记录HTTP信息头`
1. http代理服务器：
  - 添加过滤条件：`(?i).*\.(bmp|css|js|gif|ico|jpe?g|png|swf|woff|woff2|svg|ttf)`
    ![](https://upload-images.jianshu.io/upload_images/3986094-0c9cb3afc09cddff.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/800)
1. 打开浏览器，网络设置，将局域网设置中的代理服务器设为localhost，端口设置为8888
1. 代理服务器配置后之后，点击`HTTP代理服务器`启动按钮，代理服务器就会开始记录所接受的http请求
1. 在浏览器地址栏输入需要测试的地址并进行相关操作，完成第一组录制
1. 得到第一组录制的结果后，将任意一个请求的`HTTP信息头管理器`移至`测试计划` → `线程组`使其成为全局`HTTP信息头管理器`
    ![](https://upload-images.jianshu.io/upload_images/3986094-93fe64e2e7f485e0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
1. `HTTP代理服务器`中取消勾选：`记录HTTP信息头`，重启`HTTP代理服务器`
1. 删除录制的第一组信息，重新进行录制
1. 脚本录制完毕，处理一下`HTTP信息头管理器`，添加或修改需要的信息头后即可开始进行压测

### 远程测试

- 部署从节点

  ```
  kubectl apply -f jmeter-slaver.yaml -n jmeter
  ```

- 运行控制端

  ```
  kubectl run jmeter-master --image=setzero/jmeter:5.1.1 -it --restart=Never --command -- bash
  ```

- 另开窗口，将保存的脚本复制到jmeter-master pod中

  ```
  kubectl cp self.jmx jmeter-master:/
  ```

- 在控制端，执行压测
  ```
  jmeter -Dserver.rmi.ssl.disable=true \
      -n \
      -t /self.jmx \
      -l /result.jtl \
      -R jmeter-0.jmeter.jmeter.svc,\
         jmeter-1.jmeter.jmeter.svc,\
         jmeter-2.jmeter.jmeter.svc,\
         jmeter-3.jmeter.jmeter.svc,\
         jmeter-4.jmeter.jmeter.svc
  ```

- 另开窗口，保存压测结果

  ```
  kubectl cp jmeter-master:/result.jtl .
  ```

- 将压测报告导成html

  ```
  jmeter -g result.jtl -o result
  ```