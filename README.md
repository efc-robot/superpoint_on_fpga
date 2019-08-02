# superpoint_on_fpga

## 准备工作

1. 安装[vivado19.1](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools.html)
2. 下载[DPR TRD v1.0](https://www.xilinx.com/products/design-tools/ai-inference/ai-developer-hub.html#edge)，并解压
3. The following tutorials assume that the $TRD_HOME environment variable is set as given below.

```
% export TRD_HOME=</path/to/downloaded/zipfile>/zcu102-dpu-trd-2018-2
```

## 制作vivado工程
> 具体操作可以参考$TRD_HOME/下的readme.md

### On Linux:

1. Open a Linux terminal
2. Change directory to $TRD_HOME/pl
3. Run the following command in Vivado shell to create the Vivado IPI project and invoke the GUI for DPU TRD hardware design.

```
% vivado -source scripts/trd_prj.tcl
```

4. Change directory to $TRD_HOME/pl/prj/zcu102.srcs/sources_1/
5. Clone本仓库的内容，并添加到vivado工程中

```
% git clone https://github.com/xxzzll11111/superpoint_on_fpga
```

6. Click on “**Generate Bitstream**”.

