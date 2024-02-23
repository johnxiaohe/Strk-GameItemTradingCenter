# GOLD
基于StarkNet网络的全链游戏道具物品交易中心模组，可让全链游戏专注游戏内容开发，游戏通用道具等可接入该模组完成交易市场构建。

## 背景
一个好的吸引人的WEB3链想要吸引更多开发者来此开发，应该提供出更便利的开发工具、开发框架或者链上合作生态模组，来帮助项目团队更快速的完成项目开发搭建。而在游戏领域，交易行在网游中基本又必不可少却又时长可以引发安全漏洞的一环，这个会让开发团队费神费时从而耽误开发进度，尤其是WEB3领域链游玩家对交易属性尤其看重，如果可以提供出来一个安全可靠的交易行模块供项目组直接接入可以保证项目组将主要精力放在打磨游戏玩法上，更快的完成项目。并且该项目又将保证其安全性和物品丢失的赔付问题。

## 功能
出售
求购
拍卖
提供接口调用
https://github.com/starkware-libs/cairo/blob/main/docs/reference/src/components/cairo/modules/language_constructs/pages/naming-conventions.adoc

scarb new projectname
scarb cairo-run
scarb test

环境准备
stark账户创建工具  starkli
curl https://get.starkli.sh | sh
. /home/codespace/.starkli/env
starkliup -v 0.1.20
升级: starkliup

账号创建
创建密钥存放位置
mkdir ~/.starknet_accounts
生成私钥
starkli signer keystore new ~/.starknet_accounts/key.json
输入私钥密码  Enter password: 
生成: Public key

配置私钥到环境变量
export STARKNET_KEYSTORE=~/.starknet_accounts/key.json
配置RPC节点地址
export STARKNET_RPC=https://starknet-testnet.public.blastapi.io

创建账户(生成json的账户配置文件)
starkli account oz init ~/.starknet_accounts/starkli.json
部署账户
starkli account deploy ~/.starknet_accounts/starkli.json

合约调用
调用合约查询api
starkli call 0x0091efcd6807d63d83ceb1ce1912c039d7533cfbe54e820711ce406e726b2d4a name
转换字符串
starkli parse-cairo-string 字符串16进制码

配置starknet账户地址到环境变量
export STARKNET_ACCOUNT=~/.starknet_accounts/starkli.json

调用合约方法发送交易
starkli invoke 0x0091efcd6807d63d83ceb1ce1912c039d7533cfbe54e820711ce406e726b2d4a mint u256:10000

starkli call 0x0091efcd6807d63d83ceb1ce1912c039d7533cfbe54e820711ce406e726b2d4a balanceOf account_address

部署合约
scarb build 
上传编译文件
starkli declare target/dev/contract_class.json
部署合约
starkli deploy class_hash construct_args(eg. str:HELLO str:HE 18)

领水
https://faucet.goerli.starknet.io