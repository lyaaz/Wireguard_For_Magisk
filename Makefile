# Makefile for Windows

# 定义变量
SOURCE_DIR := bin,META-INF,scripts,customize.sh,module.prop,service.sh,uninstall.sh
ZIP_NAME := Wireguard_For_Magisk.zip

# 默认目标
all: zip

# 打包文件为 zip
zip:
	@echo "Creating zip file..."
	@powershell Compress-Archive -Path $(SOURCE_DIR) -DestinationPath $(ZIP_NAME)
	@echo "Zip file created: $(ZIP_NAME)"

# 清理生成的文件
clean:
	@echo "Cleaning up..."
	@powershell -Command "if (Test-Path $(ZIP_NAME)) { Remove-Item $(ZIP_NAME) }"
	@echo "Cleanup complete."

# 帮助信息
help:
	@echo "Available targets:"
	@echo "  all    : Build the zip file."
	@echo "  clean  : Remove the generated zip file."
	@echo "  help   : Show this help message."

# 防止与文件同名的伪目标冲突
.PHONY: all zip clean help
