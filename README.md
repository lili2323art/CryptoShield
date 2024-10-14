# 项目名称

## 项目简介

在off-chain中，使用LLM的RAG技术，实时地识别能够触发智能合约的潜在恶意交易

## 技术栈

- **wagmi**: 用于与以太坊进行交互。
- **shadcn**: UI组件库。
- **Tailwind CSS**: 用于快速构建响应式设计。
- **TypeScript**: 提供静态类型检查。
- **Next.js**: 用于构建React应用的框架。
- **viem**: 用于以太坊的工具库。

## 项目结构

- `./dapp`: 存放DApp代码。
- `./contract`: 存放智能合约代码。
- `./LLM_verifacion`：存放大语言模型验证的代码

## 安装与运行

### 前端DApp

1. 克隆项目到本地:
   ```bash
   git clone <repository-url>
   ```

2. 进入`dapp`目录并安装依赖:
   ```bash
   cd dapp
   npm install
   ```

3. 启动开发服务器:
   ```bash
   npm run dev
   ```

4. 在浏览器中打开 [http://localhost:3000](http://localhost:3000) 查看效果。

### 智能合约

1. 进入`contract`目录并安装依赖:
   ```bash
   cd contract
   forge install
   ```

2. 编译合约:
   ```bash
   forge build
   ```

3. 运行测试:
   ```bash
   forge test
   ```
### LLM-RAG
输入defi.ai的api key，然后运行
```bash
python3 LLM_verifacion/main.py
```

## 部署

### 部署DApp

使用 [Vercel](https://vercel.com/) 部署Next.js应用。详细步骤请参考 [Next.js部署文档](https://nextjs.org/docs/deployment)。

### 部署智能合约

使用Foundry工具进行合约部署:

