# EG4S20 HDMI 多媒体播放系统

目标板：HX4S20，器件：EG4S20BG256。工程默认采用 640×480@60 Hz HDMI-B 输出，后续可在
HDMI TX 与 PLL 通过后切换到 1280×720。

## 已包含的自定义 RTL

- `rtl/common`：PLL lock 同步复位、同步 FIFO、按键去抖。
- `rtl/control`：上电装载、图片切换、播放/暂停、自动轮播、特效与亮度/对比度控制。
- `rtl/media/bmp_decoder.v`：无压缩、24-bit BMP 的 BGR888 到 RGB565 解码基础实现。
- `rtl/memory`：供应商 SDRAM 核的 16-bit 像素适配、显示优先仲裁、双帧地址交换。
- `rtl/video`：640×480 视频时序。
- `rtl/hdmi`：HDMI core/PHY 适配层和 HDMI audio ACR 计算模块。

## Tang Dynasty 导入顺序

1. 新建 EG4S20BG256 工程，顶层最终命名为 `eg4s20_hdmi_player_top`。
2. 加入 `constraints/eg4s20_hdmi_player.adc` 和 `.sdc`；在实现前依据 TD 的 HDMI IP 提示确认 HDMI-B 的差分 I/O 标准。
3. 按 `ip/README.md` 导入安路 HDMI 与 SDRAM 参考核，并为 50 MHz 输入重新生成 PLL。不要加入 PH1A 的 `pll.ipc`、`.adc` 或 `.sdc`。
4. 将 `rtl/` 和 `sim/` 加入工程；先用 `tb_sync_fifo.v`、`tb_video_timing_640x480.v`、`tb_key_filter.v`、`tb_ui_controller.v`、`tb_bmp_decoder.v`、`tb_sdram_arbiter.v`、`tb_frame_buffer_ctrl.v` 做模块仿真。
5. HDL 仿真通过后，先连接 `video_timing + hdmi_tx_eg4s20` 输出测试图；再接入 SDRAM 与 TF/FAT32/WAV 模块。

## TF 素材约定

TF 卡使用 FAT32。图片采用 8.3 短文件名，例如 `PIC0001.BMP`；首版图片要求为 640×480、
24-bit、无压缩 BMP。音频采用 `AUD0001.WAV`，PCM、48 kHz、16-bit、双声道。

## 当前验证边界

本交付环境未安装 Tang Dynasty、Icarus Verilog 或 Verilator，因此随附的 testbench 尚未在此处运行。
HDMI/PLL/SDRAM IP 为安路加密或工具生成资源，必须在安装 TD 的开发机中生成并完成最终综合、布局布线、bitstream 与时序报告。
