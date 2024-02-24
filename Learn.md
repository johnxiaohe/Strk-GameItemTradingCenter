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